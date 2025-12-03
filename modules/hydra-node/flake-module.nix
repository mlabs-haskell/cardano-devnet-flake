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
      options.hydra-node = (import ./options.nix { inherit lib pkgs; }).options.hydra-node;
    }
    // {
      options.hydra-node.dataDir = lib.mkOption {
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
      hydra-node = import ./devnet.nix {
        inherit pkgs;
        inherit (config.hydra-node)
          package
          nodeId
          listen
          apiPort
          peers
          nodeSocket
          networkMagic
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
      packages.hydra-node = hydra-node;
    };
}
