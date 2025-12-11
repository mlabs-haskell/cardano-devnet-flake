{
  pkgs,
  lib,
  package,
  nodeId,
  listen,
  apiPort,
  peers,
  nodeSocket,
  networkMagic,
  hydraSigningKey,
  cardanoSigningKey,
  ledgerProtocolParameters,
  hydraScriptsTxId,
  hydraScriptsTxIdFile,
  dataDir,
}:

let
  hydraScriptsTxIdResolved =
    if builtins.isNull hydraScriptsTxId then "$(cat ${hydraScriptsTxIdFile})" else hydraScriptsTxId;

in
pkgs.writeShellApplication {
  name = "hydra-node";
  runtimeInputs = [
    package
    pkgs.etcd
  ];
  text = ''
    set -eo pipefail
    set -ex

    [ -d "${dataDir}" ] && { echo "Cleaning up directory ${dataDir}" ; rm -rf "${dataDir}" ; }

    hydra-node \
      --node-id ${nodeId} \
      --listen ${listen} \
      --api-port ${builtins.toString apiPort} \
      ${
        lib.concatStrings (
          map (peer: ''
            --peer 127.0.0.1:${builtins.toString peer.port} \
            --cardano-verification-key ${peer.cardanoVerificationKey} \
            --hydra-verification-key ${peer.hydraVerificationKey} \
          '') peers
        )
      } \
      --persistence-dir ${dataDir} \
      --node-socket ${nodeSocket} \
      --testnet-magic ${builtins.toString networkMagic} \
      --cardano-signing-key ${cardanoSigningKey} \
      --hydra-signing-key ${hydraSigningKey} \
      --ledger-protocol-parameters ${ledgerProtocolParameters} \
      --use-system-etcd \
      --hydra-scripts-tx-id "${hydraScriptsTxIdResolved}"
  '';
}
