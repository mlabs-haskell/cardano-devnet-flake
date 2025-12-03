{
  pkgs,
  lib,
  config,
  name,
  ...
}:
{
  # Import option declarations
  options =
    (import ../modules/cardano-devnet/options.nix { inherit lib pkgs config; }).options.cardano-devnet;

  # Set recursive defaults (settings these directly in options.nix causes issues with document
  # generation)
  config = {
    nodeSocket = lib.mkDefault "${config.dataDir}/node.socket";
  };

  # Define process-compose configuration
  config.outputs.settings.processes."${name}" =
    let
      cardano-devnet = import ../modules/cardano-devnet/devnet.nix {
        inherit pkgs;
        inherit (config)
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
          dataDir
          nodeSocket
          ;
      };

    in
    {
      command = cardano-devnet;
      readiness_probe = {
        exec.command = ''
          ${config.cardano-cli}/bin/cardano-cli query tip \
          --socket-path ${config.dataDir}/node.socket \
          --testnet-magic ${builtins.toString config.networkMagic}'';
        initial_delay_seconds = 1;
        period_seconds = 1;
      };
    };
}
