{
  pkgs,
  lib,
  config,
  name,
  ...
}:
{
  # Import option declarations
  options =
    (import ../modules/hydra-node/options.nix { inherit lib pkgs config; }).options.hydra-node;

  # Set recursive defaults (settings these directly in options.nix causes issues with document
  # generation)
  config = {
    walletDir = lib.mkDefault "${config.src}/wallets";
    ledgerProtocolParameters = lib.mkDefault "${config.src}/protocol-params.json";
    hydraScriptsTxIdFile = lib.mkDefault "${config.dataDir}/hydra-scripts-tx-id";
  };

  # Define process-compose configuration
  config.outputs.settings.processes = {
    "${name}" =
      let
        hydra-node = import ../modules/hydra-node/node.nix {
          inherit pkgs lib;
          inherit (config)
            package
            nodeId
            listen
            apiPort
            peers
            nodeSocket
            networkMagic
            hydraSigningKey
            cardanoSigningKey
            ledgerProtocolParameters
            hydraScriptsTxId
            hydraScriptsTxIdFile
            dataDir
            ;
        };

      in
      {
        command = hydra-node;
        readiness_probe = {
          http_get = {
            host = "127.0.0.1";
            port = config.apiPort;
            path = "/head";
          };
          initial_delay_seconds = 2;
          period_seconds = 2;
        };
        depends_on = {
          ${config.devnetName}.condition = "process_healthy";
          "hydra-publish-scripts".condition = "process_completed_successfully";
        };

      };
  }
  // lib.optionalAttrs config.publishScripts {
    "hydra-publish-scripts" =
      let
        hydra-publish-script = pkgs.writeShellApplication {
          name = "hydra-publish-scripts";
          runtimeInputs = [
            config.package
            pkgs.etcd
          ];
          text = ''
            mkdir -p $(dirname {config.hydraScriptsTxIdFile})

            hydra-node publish-scripts \
              --node-socket ${config.nodeSocket} \
              --testnet-magic 2  \
              --cardano-signing-key ${config.cardanoSigningKey} | tee ${config.hydraScriptsTxIdFile}
          '';
        };
      in
      # We only want the init script to run once regardless of the number of nodes
      {
        command = hydra-publish-script;
        depends_on.${config.devnetName}.condition = "process_healthy";
      };
  };
}
