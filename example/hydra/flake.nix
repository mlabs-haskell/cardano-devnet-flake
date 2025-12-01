{
  description = "Using Cardano devnet as process-compose service";

  inputs = {
    cardano-devnet.url = "path:../..";
    flake-parts.follows = "cardano-devnet/flake-parts";

    process-compose.url = "github:Platonic-Systems/process-compose-flake";

    cardano-node.url = "github:IntersectMBO/cardano-node/10.1.4";
    nixpkgs.follows = "cardano-node/nixpkgs";

    ogmios.url = "github:mlabs-haskell/ogmios-nix/v6.11.2";

    hydra.url = "github:cardano-scaling/hydra/1.2.0";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [
        inputs.process-compose.flakeModule
      ];

      perSystem =
        {
          pkgs,
          self',
          inputs',
          system,
          ...
        }:
        {

          process-compose.hydra-example = {
            imports = [
              inputs.cardano-devnet.processComposeModule
            ];

            services.cardano-devnet."devnet" = {
              inherit (inputs.cardano-node.packages.${system}) cardano-node cardano-cli;
              enable = true;
              initialFundsKeyType = "verification-key-file";
              initialFunds = {
                "example/hydra/wallets/dev-2.vk" = 45000000000000000;
              };
              networkMagic = 2;
            };

            settings.processes = {
              ogmios = {
                command = ''
                  ${inputs'.ogmios.packages."ogmios:exe:ogmios"}/bin/ogmios \
                    --node-socket data/cardano-devnet/node.socket \
                    --node-config data/cardano-devnet/config.json
                '';
                readiness_probe = {
                  http_get = {
                    host = "127.0.0.1";
                    port = 1337;
                    path = "/health";
                  };
                  initial_delay_seconds = 2;
                  period_seconds = 2;
                };
                depends_on.devnet.condition = "process_healthy";
              };

              hydra-publish-script = {
                command = ''
                  ${inputs'.hydra.packages.hydra-node}/bin/hydra-node publish-scripts \
                    --node-socket data/cardano-devnet/node.socket \
                    --testnet-magic 2  \
                    --cardano-signing-key wallets/dev-1.sk > data/hydra-scripts-tx-id
                '';
                depends_on.devnet.condition = "process_healthy";

              };

              hydra-node-1 = {
                command = ''
                  ${inputs'.hydra.packages.hydra-node}/bin/hydra-node \
                    --node-id 1 \
                    --listen 127.0.0.1:5001 \
                    --api-port 4001 \
                    --peer 127.0.0.1:5002 \
                    --persistence-dir data/hydra-1 \
                    --node-socket data/cardano-devnet/node.socket \
                    --testnet-magic 2 \
                    --hydra-signing-key wallets/hydra-key-2.sk \
                    --hydra-verification-key wallets/hydra-key-1.vk \
                    --hydra-verification-key wallets/hydra-key-2.vk \
                    --cardano-signing-key wallets/dev-1.sk \
                    --cardano-verification-key wallets/dev-1.vk \
                    --cardano-verification-key wallets/dev-2.vk \
                    --ledger-protocol-parameters protocol-params.json \
                    --use-system-etcd \
                    --hydra-scripts-tx-id $(cat data/hydra-scripts-tx-id)
                '';
                depends_on.hydra-publish-script.condition = "process_completed_successfully";
              };

              hydra-node-2 = {
                command = ''
                  ${inputs'.hydra.packages.hydra-node}/bin/hydra-node \
                    --node-id 2 \
                    --listen 127.0.0.1:5002 \
                    --api-port 4002 \
                    --peer 127.0.0.1:5001 \
                    --persistence-dir data/hydra-2 \
                    --node-socket data/cardano-devnet/node.socket \
                    --testnet-magic 2 \
                    --hydra-signing-key wallets/hydra-key-2.sk \
                    --hydra-verification-key wallets/hydra-key-1.vk \
                    --hydra-verification-key wallets/hydra-key-2.vk \
                    --cardano-signing-key wallets/dev-2.sk \
                    --cardano-verification-key wallets/dev-1.vk \
                    --cardano-verification-key wallets/dev-2.vk \
                    --ledger-protocol-parameters protocol-params.json \
                    --use-system-etcd \
                    --hydra-scripts-tx-id $(cat data/hydra-scripts-tx-id)
                '';
                depends_on.hydra-publish-script.condition = "process_completed_successfully";
              };
            };
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              self'.packages.hydra-example
              inputs'.cardano-node.packages.cardano-cli
              inputs'.hydra.packages.hydra-node
              pkgs.etcd
            ];
          };
        };
    };
}
