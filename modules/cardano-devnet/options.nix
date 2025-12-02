{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.cardano-devnet = {
    cardano-node = lib.mkPackageOption pkgs "cardano-node" { };

    cardano-cli = lib.mkPackageOption pkgs "cardano-cli" { };

    nodeSocket = lib.mkOption {
      type = lib.types.str;
      default = "${config.dataDir}/node.socket";
      description = ''
        Filepath to local unix domain socket.
      '';
    };

    initialFundsKeyType = lib.mkOption {
      type = lib.types.str;
      default = "verification-key-hash";
      example = "bech32-binary";
      description = "Flag to define the keys used in `initialFunds` option (bech32-binary | verification-key-file | verification-key-hash)";
    };

    initialFunds = lib.mkOption {
      type = lib.types.attrsOf lib.types.ints.unsigned;
      example = {
        "9783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
      };
      description = "Wallet public key - lovelace pair, determining the initial funds. Use `initialFundsKeyType` define the key type you're using and maxLovelaceSupply to increase the distributeable amount if needed.";
    };

    walletDir = lib.mkOption {
      type = lib.types.path;
      description = "Directory where verification keys are located.";
    };

    maxLovelaceSupply = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 45000000000000000;
      description = "Maximum lovelace amount that can ever exist on the network.";
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

  };
}
