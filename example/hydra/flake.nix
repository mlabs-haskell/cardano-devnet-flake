{
  description = "Cardano devnet with a Hydra head";

  inputs = {
    cardano-devnet.url = "path:../..";
    flake-parts.follows = "cardano-devnet/flake-parts";

    process-compose.url = "github:Platonic-Systems/process-compose-flake";

    cardano-node.url = "github:IntersectMBO/cardano-node/10.5.3";
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
          config,
          ...
        }:
        let
          config' = config.process-compose.hydra-example;
        in
        {
          process-compose.hydra-example = {
            imports = [
              inputs.cardano-devnet.processComposeModule
            ];

            services = {
              cardano-devnet."devnet" = {
                enable = true;
                inherit (inputs'.cardano-node.packages) cardano-node cardano-cli;
                walletDir = ./wallets;
                initialFundsKeyType = "verification-key-file";
                initialFunds = {
                  "cardano-key-1.vk" = 45000000000000000;
                  "cardano-key-2.vk" = 45000000000000000;
                };
                networkMagic = 2;
              };

              hydra-node."hydra-node-1" = {
                enable = true;
                inherit (config'.services.cardano-devnet."devnet") nodeSocket networkMagic;
                devnetName = "devnet";
                src = ./.;
                listen = "127.0.0.1:5001";
                apiPort = 4001;
                package = inputs'.hydra.packages.hydra-node;
                cardanoSigningKey = ./wallets/cardano-key-1.sk;
                hydraSigningKey = ./wallets/hydra-key-1.sk;
                peers = [
                  {
                    port = 5002;
                    cardanoVerificationKey = ./wallets/cardano-key-2.vk;
                    hydraVerificationKey = ./wallets/hydra-key-2.vk;
                  }
                ];
                publishScripts = true;
              };

              hydra-node."hydra-node-2" = {
                enable = true;
                inherit (config'.services.cardano-devnet."devnet") nodeSocket networkMagic;
                devnetName = "devnet";
                src = ./.;
                listen = "127.0.0.1:5002";
                apiPort = 4002;
                package = inputs'.hydra.packages.hydra-node;
                cardanoSigningKey = ./wallets/cardano-key-2.sk;
                hydraSigningKey = ./wallets/hydra-key-2.sk;
                peers = [
                  {
                    port = 5001;
                    cardanoVerificationKey = ./wallets/cardano-key-1.vk;
                    hydraVerificationKey = ./wallets/hydra-key-1.vk;
                  }
                ];
              };
            };
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              self'.packages.hydra-example
              inputs'.cardano-node.packages.cardano-cli
              inputs'.cardano-node.packages.cardano-node
              inputs'.hydra.packages.hydra-node
              pkgs.etcd
              pkgs.boxes
            ];
            shellHook = ''
              boxes -d peek -p h2v1 << EOF
                Welcome to the cardano-devnet-flake example.
                Run hydra-example to start process-compose services
              EOF
            '';
          };

        };

      debug = true;
    };
}
