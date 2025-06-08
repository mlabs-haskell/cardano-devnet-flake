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
        cardano-node = lib.mkPackageOption pkgs "cardano-node" { };

        cardano-cli = lib.mkPackageOption pkgs "cardano-cli" { };

        initialFundsKeyType = lib.mkOption {
          type = lib.types.string;
          default = "verification-key-hash";
          example = "bech32-binary";
          description = "Flag to define the keys used in `initialFunds` option (bech32-binary | verification-key-file | verification-key-hash)";
        };

        initialFunds = lib.mkOption {
          type = lib.types.attrsOf lib.types.ints.unsigned;
          example = {
            "9783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
          };
          description = "Wallet public key - lovelace pair, determining the initial funds. Use `initialFundsKeyType` define the key type you're using.";
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
          initialFundsKeyType
          cardano-node
          cardano-cli
          ;
      };

    in
    {
      packages.cardano-devnet = cardano-devnet;
    };
}
