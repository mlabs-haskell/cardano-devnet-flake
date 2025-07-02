{
  description = "Using Cardano devnet as process-compose service";

  inputs = {
    cardano-devnet.url = "path:../..";
    flake-parts.follows = "cardano-devnet/flake-parts";

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
          ...
        }:
        {

          process-compose.process-compose-example = {
            imports = [
              inputs.cardano-devnet.processComposeModule
            ];

            services.cardano-devnet."devnet" = {
              inherit (inputs.cardano-node.packages.${system}) cardano-node cardano-cli;
              enable = true;
              initialFundsKeyType = "verification-key-file";
              initialFunds = {
                "example/process-compose-module/wallets/dev.vk" = 45000000000000000;
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
            };
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              self'.packages.process-compose-example
            ];
          };
        };
    };
}
