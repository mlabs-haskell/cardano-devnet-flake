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
