{
  description = "Using Cardano devnet as NixOS flake parts module";

  inputs = {
    cardano-devnet.url = "path:../..";

    flake-parts.follows = "cardano-devnet/flake-parts";
    cardano-node.url = "github:IntersectMBO/cardano-node/10.1.4";
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

      imports = [ inputs.cardano-devnet.flakeModule ];

      debug = true;

      perSystem =
        {
          pkgs,
          config,
          system,
          ...
        }:
        {
          cardano-devnet = {
            package = inputs.cardano-node.packages.${system}.cardano-node;
            initialFunds = {
              "609783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
            };
            networkMagic = 2;
          };

          devShells.default = pkgs.mkShell {

            buildInputs = [
              config.packages.cardano-devnet
            ];
          };
        };
    };
}
