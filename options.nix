{ lib, pkgs }:
{
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
      example = 2;
      description = "Cardano network magic id (also known as testnet magic).";
    };

    networkId = lib.mkOption {
      type = lib.types.str;
      default = "Testnet";
      example = "Mainnet";
      description = "Network discriminant which can be Mainnet or Testnet";
    };

    epochLength = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 5;
      example = 100;
      description = "Length of an epoch in slots";
    };

    slotLength = lib.mkOption {
      type = lib.types.float;
      default = 0.1;
      example = 1;
      description = "Slot duration in seconds";
    };

    maxTxSize = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 16384;
      example = 20000;
      description = "Transaction size in bytes";
    };

    maxBlockExUnits = lib.mkOption {
      type = lib.types.attrsOf lib.types.ints.unsigned;
      default = {
        exUnitsMem = 62000000;
        exUnitsSteps = 40000000000;
      };
      example = {
        exUnitsMem = 62000000;
        exUnitsSteps = 40000000000;
      };
      description = "Maximum execution budget for a block";
    };

    maxTxExUnits = lib.mkOption {
      type = lib.types.attrsOf lib.types.ints.unsigned;
      default = {
        exUnitsMem = 14000000;
        exUnitsSteps = 10000000000;
      };
      example = {
        exUnitsMem = 14000000;
        exUnitsSteps = 10000000000;
      };
      description = "Maximum execution budget for a transaction";
    };

    protocolVersion = lib.mkOption {
      type = lib.types.attrsOf lib.types.ints.unsigned;
      default = {
        major = 10;
        minor = 0;
      };
      example = {
        major = 6;
        minor = 0;
      };
      description = "Protocol major and minor version";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "./data/cardano-devnet";
      description = "The directory where all data for `cardano-devnet.<name>` is stored";
    };
  };
}
