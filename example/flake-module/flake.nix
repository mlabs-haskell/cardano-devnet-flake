{
  description = "Using Cardano devnet as NixOS flake parts module";

  inputs = {
    cardano-devnet.url = "path:../..";
    flake-parts.follows = "cardano-devnet/flake-parts";

    cardano-node.url = "github:IntersectMBO/cardano-node/10.4.1";
    nixpkgs.follows = "cardano-node/nixpkgs";
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
        inputs.cardano-devnet.flakeModule
      ];

      perSystem =
        {
          pkgs,
          config,
          inputs',
          ...
        }:
        {
          cardano-devnet = {
            inherit (inputs'.cardano-node.packages) cardano-node cardano-cli;
            initialFunds = {
              "9783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
            };
            networkMagic = 2;
            slotLength = 1.0;
          };

          devShells.default = pkgs.mkShell {

            buildInputs = [
              config.packages.cardano-devnet
            ];
          };

        };
    };
}
