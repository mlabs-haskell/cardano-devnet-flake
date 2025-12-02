{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    hydra-devnet = {
      package = lib.mkPackageOption pkgs "hydra-node" { };

      node-id = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = ''
          The Hydra node identifier used on the Hydra network.
          It is important to have a unique identifier in order
          to be able to distinguish between connected peers.
        '';
      };

      listen = lib.mkOption {
        type = lib.types.string;
        default = "127.0.0.1:5001";
        description = ''
          Address and port to listen for Hydra network
          connections. 
        '';
      };

      api-port = lib.mkOption {
        type = lib.types.string;
        default = "4001";
        description = ''
          Listen port for incoming client API connections.
        '';
      };

      peers = lib.mkOption {
        type = lib.types.listOf lib.types.string;
        default = "127.0.0.1:5002";
        description = ''
          Peer addresses in the form <host>:<port>, where
          <host> can be an IP address, or a host name. 
          (current maximum limit is 7 peers).
        '';
      };

      persistence-dir = lib.mkOption {
        type = lib.types.path;
        default = ./data/hydra-1;
        description = ''
          The directory where the Hydra Head state is stored.Do
          not edit these files manually!
        '';
      };

      node-socket = lib.mkOption {
        type = lib.types.path;
        default = ./data/cardano-devnet/node.socket;
        description = ''
          Filepath to local unix domain socket used to
          communicate with the cardano node.
        '';
      };

      testnet-magic = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = ''
          Network identifier for a testnet to connect to. We
          only need to provide the magic number here. For
          example: '2' is the 'preview' network. See
          https://book.world.dev.cardano.org/environments.html
        '';
      };

      hydra-signing-key = lib.mkOption {
        type = lib.types.path;
        default = ./wallets/hydra-key-2.sk;
        description = ''
          Hydra signing key used by our hydra-node.
        '';
      };

      hydra-verification-keys = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = ./wallets/hydra-key-1.vk;
        description = ''
          Hydra verification key of another party in the Head
          (current maximum limit is 7 ).
        '';
      };

      cardano-signing-key = lib.mkOption {
        type = lib.types.path;
        default = ./wallets/dev-1.sk;
        description = ''
          Cardano signing key of our hydra-node. This will be
          used to authorize Hydra protocol transactions for
          heads the node takes part in and any funds owned by
          this key will be used as 'fuel'.
        '';
      };

      cardano-verification-keys = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = ./wallets/dev-1.vk;
        description = ''
          Cardano verification keys of another parties in the
          Head (current maximum limit is 7).
        '';
      };

      ledger-protocol-parameters = lib.mkOption {
        type = lib.types.path;
        default = ./protocol-params.json;
        description = ''
          Path to protocol parameters used in the Hydra Head.
          See manual how to configure this.
        '';
      };

      hydra-scripts-tx-id = lib.mkOption {
        type = lib.types.string;

        # default = $(cat data/hydra-scripts-tx-id);

        default = config.hydra-devnet.dataDir;
        description = ''
          The transactions which are expected to have published
          Hydra scripts as reference scripts in their outputs.
          You can use the 'publish-scripts' sub-command to
          publish scripts yourself.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "./data/cardano-devnet";
        description = "The directory where all data for `hydra-devnet.<name>` is stored";
      };
    };
  };
}
# --network NETWORK        Uses the last pre-published hydra scripts for the
#                          given network.
# --offline-head-seed HEX  Offline mode: Hexadecimal seed bytes to derive the
#                          offline head id from. Needs to be consistent across
#                          the hydra-node instances.
# --initial-utxo FILE      Offline mode: File containing initial UTxO for the L2
#                          ledger in offline mode. (default: "utxo.json")
# --ledger-genesis FILE    Offline mode: File containing shelley genesis
#                          parameters for the simulated L1 chain in offline
#                          mode. (default: Nothing)
