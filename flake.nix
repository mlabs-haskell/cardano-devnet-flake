{
  description = "Local Cardano devnet";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.follows = "cardano-node/nixpkgs";
    cardano-node.url = "github:IntersectMBO/cardano-node?ref=9.1.0";
  };

  outputs = inputs@{ flake-parts, ... }: {
    flakeModule = ./cardano-devnet.nix;
  } //
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

    imports = [ ./cardano-devnet.nix ];

    debug = true;

    perSystem = { pkgs, config, ... }: {
      cardano-devnet.initialFunds = {
        "609783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
      };

      devShells.default = pkgs.mkShell
        {

          buildInputs = [
            config.packages.cardano-devnet
          ];
        };

    };
  };
}
