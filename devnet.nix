{
  pkgs,
  cardano-node,
  devnetDirectory,
  networkMagic,
  initialFunds,
}:
let
  CONFIG_DIR = ./devnet;
  CARDANO_NODE_SOCKET_PATH = "${devnetDirectory}/node.socket";
in
pkgs.writeShellApplication {
  name = "cardano-devnet";
  runtimeInputs = [
    cardano-node
    pkgs.jq
  ];
  text = ''
    export CARDANO_NODE_SOCKET_PATH=${CARDANO_NODE_SOCKET_PATH}

    set -eo pipefail
    set -ex

    [ -d "${devnetDirectory}" ] && { echo "Cleaning up directory ${devnetDirectory}" ; rm -rf "${devnetDirectory}" ; }

    mkdir -p ${devnetDirectory}

    cp -af ${CONFIG_DIR}/config.json "${devnetDirectory}"
    cp -af ${CONFIG_DIR}/genesis-alonzo.json "${devnetDirectory}"
    cp -af ${CONFIG_DIR}/genesis-conway.json "${devnetDirectory}"
    cp -af ${CONFIG_DIR}/vrf.skey "${devnetDirectory}"
    cp -af ${CONFIG_DIR}/kes.skey "${devnetDirectory}"

    jq '.startTime |= $start_time | .protocolConsts.protocolMagic |= $network_magic' \
      --argjson start_time "$(date +%s)" \
      --argjson network_magic ${builtins.toJSON networkMagic} \
      < ${CONFIG_DIR}/genesis-byron.json \
      > "${devnetDirectory}/genesis-byron.json"

    jq '.systemStart |= $start_time | .initialFunds |= $funds | .networkMagic |= $network_magic' \
      --arg start_time "$(date -u +%FT%TZ)" \
      --argjson funds '${builtins.toJSON initialFunds}' \
      --argjson network_magic ${builtins.toJSON networkMagic} \
      < ${CONFIG_DIR}/genesis-shelley.json\
      > "${devnetDirectory}/genesis-shelley.json"

    find "${devnetDirectory}" -type f -name '*.skey' -exec chmod 0400 {} \;
    mkdir "${devnetDirectory}/ipc"

    cardano-node run \
      --topology "${CONFIG_DIR}/topology.json" \
      --database-path "${devnetDirectory}/chain" \
      --socket-path "${CARDANO_NODE_SOCKET_PATH}" \
      --port 3001 \
      --config "${devnetDirectory}/config.json" \
      --shelley-kes-key "${devnetDirectory}/kes.skey" \
      --shelley-vrf-key "${devnetDirectory}/vrf.skey" \
      --shelley-operational-certificate "${CONFIG_DIR}/opcert.cert" \
      --byron-delegation-certificate "${CONFIG_DIR}/byron-delegation.cert" \
      --byron-signing-key "${CONFIG_DIR}/byron-delegate.key"
  '';
}
