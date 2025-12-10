{
  lib,
  pkgs,
  ...
}:
{
  options.hydra-node = {
    package = lib.mkPackageOption pkgs "hydra-node" { };

    devnetName = lib.mkOption {
      type = lib.types.str;
      default = "cardano-devnet";
      description = ''
        Name of the devnet this Hydra node is connecting to. This is required to
        configure dependencies between processes in process-compose.
      '';
    };

    nodeId = lib.mkOption {
      type = lib.types.str;
      defaultText = ''$\{name\}'';
      description = ''
        The Hydra node identifier used on the Hydra network.
        It is important to have a unique identifier in order
        to be able to distinguish between connected peers.
        Defaults to the process-compose name of the node.
      '';
    };

    listen = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:5001";
      description = ''
        Address and port to listen for Hydra network connections. 
      '';
    };

    apiPort = lib.mkOption {
      type = lib.types.port;
      default = 4001;
      description = ''
        Listen port for incoming client API connections.
      '';
    };

    peers = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            port = lib.mkOption {
              type = lib.types.port;
              description = ''Localhost port of the peer node.'';
            };
            cardanoVerificationKey = lib.mkOption {
              type = lib.types.path;
              description = ''Cardano verification key file path.'';
            };
            hydraVerificationKey = lib.mkOption {
              type = lib.types.path;
              description = ''Hydra verification key file path.'';
            };
          };
        }
      );
      default = [ ];
      example = lib.literalExpression ''
        [
          {
            port = 5002;
            cardanoVerificationKey = ./wallets/dev-1.vk;
            hydraVerificationKey = ./wallets/hydra-key-1.vk;
          }
        ]
      '';
      description = ''
        Peer addresses and keys. Each list item contains a port, a cardano-verification-key and a
        hydra-verification-key (current maximum limit is 7 peers).
      '';
    };

    nodeSocket = lib.mkOption {
      type = lib.types.str;
      description = ''
        Filepath to local unix domain socket used to communicate with the cardano node.
      '';
    };

    networkMagic = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = ''
        Network identifier for a testnet to connect to. We only need to provide the magic number
        here. For example: '2' is the 'preview' network. See
        https://book.world.dev.cardano.org/environments.html
      '';
    };

    hydraSigningKey = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression "./wallets/hydra-key-2.sk";
      description = ''
        Hydra signing key used by our hydra-node.
      '';
    };

    src = lib.mkOption {
      type = lib.types.path;
      description = "Directory where verification keys are located.";
    };

    walletDir = lib.mkOption {
      type = lib.types.path;
      defaultText = lib.literalExpression "$\{config.src\}/wallets";
      description = "Directory where verification keys are located.";
    };

    cardanoSigningKey = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression "./wallets/dev-1.sk";
      description = ''
        Cardano signing key of our hydra-node. This will be used to authorize Hydra protocol
        transactions for heads the node takes part in and any funds owned by this key will be used
        as 'fuel'.
      '';
    };

    ledgerProtocolParameters = lib.mkOption {
      type = lib.types.path;
      defaultText = lib.literalExpression "$\{config.src\}/protocol-params.json";
      description = ''
        Path to protocol parameters used in the Hydra Head. See Hydra manual how to
        configure this.
      '';
    };

    hydraScriptsTxId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "f8161e0e4d80774277616d627582fdb622920973f39d2c6488324af98ef75269,9111793e561b8f689cfe8541ef1adefa4893171983cde9fe431e7d12451113e8,b1cc50e1f591ba5d6a6a1f2d6befe9b7951735b75dee35a0e4f5def87d984f75";
      default = null;
      description = ''
        The transactions which are expected to have published Hydra scripts as reference scripts
        in their outputs. You can use the 'publish-scripts' sub-command to publish scripts
        yourself.
      '';
    };

    hydraScriptsTxIdFile = lib.mkOption {
      type = lib.types.str;
      default = "data/hydra-scripts/tx-id";
      description = ''
        The transactions which are expected to have published Hydra scripts as reference scripts
        in their outputs. 
      '';
    };

    publishScripts = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Initialise Hydra head by publishing the scripts to the devnet and storing the result to a
        file defined by hydraScriptTxdFile.
      '';
    };

  };
}
