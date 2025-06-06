{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption (_: {
    options = {
      cardano-devnet = {
        package = lib.mkPackageOption pkgs "cardano-node" { };

        initialFunds = lib.mkOption {
          type = lib.types.attrsOf lib.types.ints.unsigned;
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
      pkgs,
      config,
      ...
    }:
    let
      cardano-devnet = import ./devnet.nix {
        inherit pkgs;
        inherit (config.cardano-devnet)
          devnetDirectory
          networkMagic
          initialFunds
          ;
        cardano-node = config.cardano-devnet.package;
      };

    in
    {
      packages.cardano-devnet = cardano-devnet;
    };
}
