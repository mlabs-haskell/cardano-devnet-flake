{
  pkgs,
  cardano-node,
  cardano-cli,
  dataDir,
  networkMagic,
  networkId,
  initialFunds,
  initialFundsKeyType,
  epochLength,
  slotLength,
  maxTxSize,
  maxBlockExUnits,
  maxTxExUnits,
  protocolVersion,
}:
let
  inherit (pkgs) lib;

  CONFIG_DIR = ./devnet;
  CARDANO_NODE_SOCKET_PATH = "${dataDir}/node.socket";

  # Initial funds as bech32-binary - lovelace pairs
  initialFundsResolved =
    if initialFundsKeyType == "bech32-binary" then
      initialFunds
    else if initialFundsKeyType == "verification-key-hash" then
      lib.mapAttrs' (
        pkh: lovelaces: lib.nameValuePair (verKeyHashToBech32Binary pkh) lovelaces
      ) initialFunds
    else if initialFundsKeyType == "verification-key-file" then
      lib.mapAttrs' (pkh: lovelaces: {
        name = verKeyHashToBech32Binary (fileToVerKeyHash pkh);
        value = lovelaces;
      }) initialFunds
    else
      throw "Invalid `initialFundsKeyType";

  verKeyHashToBech32Binary = str: "60${str}";

  fileToVerKeyHash =
    file:
    lib.removeSuffix "\n" (
      builtins.readFile (
        pkgs.runCommand "resolve-verification-key-hash-from-file-${baseNameOf file}" {
          src = builtins.path {
            path = ./.;
            name = "source";
          };
          buildInputs = [ cardano-cli ];
        } "cardano-cli address key-hash --payment-verification-key-file $src/${file} > $out"

      )
    );

in
pkgs.writeShellApplication {
  name = "cardano-devnet";
  runtimeInputs = [
    cardano-node
    pkgs.gojq
  ];
  text = ''
    export CARDANO_NODE_SOCKET_PATH=${CARDANO_NODE_SOCKET_PATH}

    set -eo pipefail
    set -ex

    [ -d "${dataDir}" ] && { echo "Cleaning up directory ${dataDir}" ; rm -rf "${dataDir}" ; }

    mkdir -p ${dataDir}

    cp -af ${CONFIG_DIR}/config.json "${dataDir}"
    cp -af ${CONFIG_DIR}/genesis-conway.json "${dataDir}"
    cp -af ${CONFIG_DIR}/vrf.skey "${dataDir}"
    cp -af ${CONFIG_DIR}/kes.skey "${dataDir}"

    # shellcheck disable=SC2016
    gojq '.startTime |= $start_time | .protocolConsts.protocolMagic |= $network_magic' \
      --argjson start_time "$(date +%s)" \
      --argjson network_magic ${builtins.toString networkMagic} \
      < ${CONFIG_DIR}/genesis-byron.json \
      > "${dataDir}/genesis-byron.json"

    # shellcheck disable=SC2016
    gojq '.systemStart |= $start_time | .initialFunds |= ($funds | map_values(tonumber)) | .networkMagic |= $network_magic | .networkId |= $network_id | .slotLength |= $slot_length | .epochLength |= $epoch_length | .protocolParams.maxTxSize |= $max_tx_size | .protocolParams.protocolVersion |= $protocol_version' \
      --arg start_time "$(date -u +%FT%TZ)" \
      --argjson funds '${builtins.toJSON initialFundsResolved}' \
      --argjson network_magic ${builtins.toString networkMagic} \
      --arg network_id ${networkId} \
      --argjson slot_length ${builtins.toString slotLength} \
      --argjson epoch_length ${builtins.toString epochLength} \
      --argjson max_tx_size ${builtins.toString maxTxSize} \
      --argjson protocol_version '${builtins.toJSON protocolVersion}' \
      < ${CONFIG_DIR}/genesis-shelley.json \
      > "${dataDir}/genesis-shelley.json"

    # shellcheck disable=SC2016
    gojq '.maxBlockExUnits |= $max_block_ex_units | .maxTxExUnits |= $max_tx_ex_units' \
      --argjson max_block_ex_units '${builtins.toJSON maxBlockExUnits}' \
      --argjson max_tx_ex_units '${builtins.toJSON maxTxExUnits}' \
      < ${CONFIG_DIR}/genesis-alonzo.json \
      > "${dataDir}/genesis-alonzo.json"

    find "${dataDir}" -type f -name '*.skey' -exec chmod 0400 {} \;
    mkdir "${dataDir}/ipc"

    cardano-node run \
      --topology "${CONFIG_DIR}/topology.json" \
      --database-path "${dataDir}/chain" \
      --socket-path "${CARDANO_NODE_SOCKET_PATH}" \
      --port 3001 \
      --config "${dataDir}/config.json" \
      --shelley-kes-key "${dataDir}/kes.skey" \
      --shelley-vrf-key "${dataDir}/vrf.skey" \
      --shelley-operational-certificate "${CONFIG_DIR}/opcert.cert" \
      --byron-delegation-certificate "${CONFIG_DIR}/byron-delegation.cert" \
      --byron-signing-key "${CONFIG_DIR}/byron-delegate.key"
  '';
}
