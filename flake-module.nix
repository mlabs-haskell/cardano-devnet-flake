{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption (_: {
    options = import ./options.nix { inherit lib pkgs; };
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
          dataDir
          networkMagic
          networkId
          initialFunds
          initialFundsKeyType
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
