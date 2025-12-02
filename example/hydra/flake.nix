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
          config,
          ...
        }:
        let
          devnetConfig = config.process-compose.hydra-example.services.cardano-devnet.devnet;
          hydraNode1Config = config.process-compose.hydra-example.services.hydra-node.hydra-node-1;
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
                  "dev-2.vk" = 45000000000000000;
                };
                networkMagic = 2;
              };

              hydra-node."hydra-node-1" = {
                enable = true;
                inherit (devnetConfig) nodeSocket networkMagic;
                devnetName = "devnet";
                src = ./.;
                listen = "127.0.0.1:5001";
                apiPort = 4001;
                package = inputs'.hydra.packages.hydra-node;
                cardanoSigningKey = ./wallets/dev-1.sk;
                hydraSigningKey = ./wallets/hydra-key-1.sk;
                peers = [
                  {
                    port = 5002;
                    cardanoVerificationKey = ./wallets/dev-2.vk;
                    hydraVerificationKey = ./wallets/hydra-key-2.vk;
                  }
                ];
                publishScripts = true;
              };

              hydra-node."hydra-node-2" = {
                enable = true;
                inherit (devnetConfig) nodeSocket networkMagic;
                devnetName = "devnet";
                src = ./.;
                listen = "127.0.0.1:5002";
                apiPort = 4002;
                package = inputs'.hydra.packages.hydra-node;
                cardanoSigningKey = ./wallets/dev-2.sk;
                hydraSigningKey = ./wallets/hydra-key-2.sk;
                hydraScriptsTxIdFile = hydraNode1Config.hydraScriptsTxIdFile;
                peers = [
                  {
                    port = 5001;
                    cardanoVerificationKey = ./wallets/dev-1.vk;
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
              inputs'.hydra.packages.hydra-node
              pkgs.etcd
            ];
          };

        };

      debug = true;
    };
}
