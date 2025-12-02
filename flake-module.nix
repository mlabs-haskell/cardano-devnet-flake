{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  options.perSystem = inputs.flake-parts.lib.mkPerSystemOption (_: {
    options =
      (import ./modules/cardano-devnet/options.nix { inherit lib pkgs config; })
      // (import ./modules/hydra-node/options.nix { inherit lib pkgs config; });
  });

  config.perSystem =
    {
      pkgs,
      config,
      ...
    }:
    let
      cardano-devnet = import ./modules/cardano-devnet/devnet.nix {
        inherit pkgs;
        inherit (config.cardano-devnet)
          dataDir
          networkMagic
          networkId
          initialFunds
          initialFundsKeyType
          walletDir
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

      hydra-node = import ./modules/hydra-node/node.nix {
        inherit pkgs lib;
        inherit (config.hydra-node)
          package
          nodeId
          listen
          apiPort
          peers
          nodeSocket
          networkMagic
          walletDir
          hydraSigningKey
          cardanoSigningKey
          ledgerProtocolParameters
          hydraScriptsTxId
          hydraScriptsTxIdFile
          dataDir
          ;
      };
    in
    {
      packages = {
        cardano-devnet = cardano-devnet;
        hydra-node = hydra-node;
      };
    };
}
