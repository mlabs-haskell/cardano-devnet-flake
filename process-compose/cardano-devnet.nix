{
  pkgs,
  lib,
  config,
  name,
  ...
}:
{
  options =
    (import ../modules/cardano-devnet/options.nix { inherit lib pkgs config; }).options.cardano-devnet;

  config.outputs.settings.processes."${name}" =
    let
      cardano-devnet = import ../modules/cardano-devnet/devnet.nix {
        inherit pkgs;
        inherit (config)
          dataDir
          nodeSocket
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
