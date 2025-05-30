{ inputs, lib, ... }:
{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption (_: {
    options = {
      cardano-devnet = {
        initialFunds = lib.mkOption {
          type = lib.types.attrsOf lib.types.ints.unsigned;
          default = { };
          example = {
            "609783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
          };
          description = "Public key - lovelace pair, determining the initial funds.";
        };

        networkMagic = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 42;
          example = 42;
          description = "Cardano network magic id";
        };

        devnetDirectory = lib.mkOption {
          type = lib.types.str;
          default = "./.devnet";
          example = "./.devnet";
          description = "Path to directory where cardano-node will temporarily store its data.";
        };
      };
    };
  });

  config.perSystem =
    {
      system,
      pkgs,
      config,
      ...
    }:
    let
      CONFIG_DIR = ./devnet;
      DEVNET_DIR = config.cardano-devnet.devnetDirectory;
      CARDANO_NODE_SOCKET_PATH = "${DEVNET_DIR}/node.socket";
      cardano-node' = inputs.cardano-node.packages.${system}.cardano-node;
      cardano-devnet = pkgs.writeShellApplication {
        name = "cardano-devnet";
        runtimeInputs = [
          cardano-node'
          pkgs.jq
        ];
        text = ''
          export CARDANO_NODE_SOCKET_PATH=${CARDANO_NODE_SOCKET_PATH}

          set -eo pipefail
          set -ex

          [ -d "${DEVNET_DIR}" ] && { echo "Cleaning up directory ${DEVNET_DIR}" ; rm -rf "${DEVNET_DIR}" ; }

          mkdir -p ${DEVNET_DIR}

          cp -af ${CONFIG_DIR}/config.json "${DEVNET_DIR}"
          cp -af ${CONFIG_DIR}/genesis-alonzo.json "${DEVNET_DIR}"
          cp -af ${CONFIG_DIR}/genesis-conway.json "${DEVNET_DIR}"
          cp -af ${CONFIG_DIR}/vrf.skey "${DEVNET_DIR}"
          cp -af ${CONFIG_DIR}/kes.skey "${DEVNET_DIR}"

          jq '.startTime |= $start_time | .protocolConsts.protocolMagic |= $network_magic' \
            --argjson start_time "$(date +%s)" \
            --argjson network_magic ${builtins.toJSON config.cardano-devnet.networkMagic} \
            < ${CONFIG_DIR}/genesis-byron.json \
            > "${DEVNET_DIR}/genesis-byron.json"

          jq '.systemStart |= $start_time | .initialFunds |= $funds | .networkMagic |= $network_magic' \
            --arg start_time "$(date -u +%FT%TZ)" \
            --argjson funds '${builtins.toJSON config.cardano-devnet.initialFunds}' \
            --argjson network_magic ${builtins.toJSON config.cardano-devnet.networkMagic} \
            < ${CONFIG_DIR}/genesis-shelley.json\
            > "${DEVNET_DIR}/genesis-shelley.json"

          find "${DEVNET_DIR}" -type f -name '*.skey' -exec chmod 0400 {} \;
          mkdir "${DEVNET_DIR}/ipc"

          cardano-node run \
            --topology "${CONFIG_DIR}/topology.json" \
            --database-path "${DEVNET_DIR}/chain" \
            --socket-path "${CARDANO_NODE_SOCKET_PATH}" \
            --port 3001 \
            --config "${DEVNET_DIR}/config.json" \
            --shelley-kes-key "${DEVNET_DIR}/kes.skey" \
            --shelley-vrf-key "${DEVNET_DIR}/vrf.skey" \
            --shelley-operational-certificate "${CONFIG_DIR}/opcert.cert" \
            --byron-delegation-certificate "${CONFIG_DIR}/byron-delegation.cert" \
            --byron-signing-key "${CONFIG_DIR}/byron-delegate.key"
        '';
      };

    in
    {
      packages.cardano-devnet = cardano-devnet;
    };
}
