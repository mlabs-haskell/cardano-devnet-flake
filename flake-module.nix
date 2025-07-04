{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption (_: {
    inherit (import ./options.nix { inherit lib pkgs; }) options;
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
