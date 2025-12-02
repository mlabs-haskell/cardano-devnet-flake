{
  description = "Using Cardano devnet as process-compose service";

  inputs = {
    cardano-devnet-flake.url = "path:../..";
    flake-parts.follows = "cardano-devnet-flake/flake-parts";

    process-compose.url = "github:Platonic-Systems/process-compose-flake";

    cardano-node.url = "github:IntersectMBO/cardano-node/10.1.4";
    nixpkgs.follows = "cardano-node/nixpkgs";

    ogmios.url = "github:mlabs-haskell/ogmios-nix/v6.11.2";
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
          config,
          ...
        }:
        let
          devnetConfig = config.process-compose.process-compose-example.services.cardano-devnet.devnet;
        in
        {

          process-compose.process-compose-example = {
            imports = [
              inputs.cardano-devnet-flake.processComposeModule
            ];

            services.cardano-devnet."devnet" = {
              enable = true;
              inherit (inputs.cardano-node.packages.${system}) cardano-node cardano-cli;
              walletDir = ./wallets;
              initialFundsKeyType = "verification-key-file";
              initialFunds = {
                "dev.vk" = 45000000000000000;
              };
              networkMagic = 2;
            };

            settings.processes = {
              ogmios = {
                command = ''
                  ${inputs'.ogmios.packages."ogmios:exe:ogmios"}/bin/ogmios \
                    --node-socket ${devnetConfig.nodeSocket} \
                    --node-config ${devnetConfig.dataDir}/config.json
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
            };
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              self'.packages.process-compose-example
            ];
          };
        };

      debug = true;
    };
}
