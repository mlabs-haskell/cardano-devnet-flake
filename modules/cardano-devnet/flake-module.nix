{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption (
    _:
    {
      inherit (import ./options.nix { inherit lib pkgs; }) options;
    }
    // {
      options.cardano-devnet.dataDir = lib.mkOption {
        type = lib.types.str;
        default = "./data/cardano-devnet";
        description = "The directory where all data for `cardano-devnet.<name>` is stored";
      };
    }
  );

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
          dataDir
          networkMagic
          networkId
          initialFunds
          initialFundsKeyType
          maxLovelaceSupply
          cardano-node
          cardano-cli
          epochLength
          slotLength
          maxTxSize
          maxBlockExUnits
          maxTxExUnits
          protocolVersion
          ;
      };

    in
    {
      packages.cardano-devnet = cardano-devnet;
    };
}
