{
  lib,
  pkgs,
  config,
  ...
}:

let
  serviceModule =
    { config, name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "Enable the cardano-devnet.<name> service";
        namespace = lib.mkOption {
          description = ''
            Namespace for the cardano-devnet service
          '';
          default = "cardano-devnet.${name}";
          type = lib.types.str;
        };
        outputs = {
          defaultProcessSettings = lib.mkOption {
            type = lib.types.deferredModule;
            internal = true;
            readOnly = true;
            description = ''
              Default settings for all processes under the cardano-devnet service
            '';
            default = {
              namespace = lib.mkDefault config.namespace;
            };
          };
          settings = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            internal = true;
            description = ''
              process-compose settings for the processes under the cardano-devnet service
            '';
            apply =
              v:
              v
              // {
                processes = lib.flip lib.mapAttrs v.processes (
                  _: cfg: {
                    imports = [
                      config.outputs.defaultProcessSettings
                      cfg
                    ];
                  }
                );
              };
          };
        };
      };
    };
  mod =
    { config, name, ... }:
    {
      options = {
        package = lib.mkPackageOption pkgs "cardano-node" { };

        cardano-cli = lib.mkPackageOption pkgs "cardano-cli" { };

        initialFunds = lib.mkOption {
          type = lib.types.attrsOf lib.types.ints.unsigned;
          example = {
            "609783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
          };
          description = "Public key - lovelace pair, determining the initial funds.";
        };

        networkMagic = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 42;
          example = 42;
          description = "Cardano network magic id";
        };

        devnetDirectory = lib.mkOption {
          type = lib.types.str;
          default = "./.devnet";
          example = "./.devnet";
          description = "Path to directory where cardano-ode will temporarily store its data.";
        };
      };

      config.outputs.settings.processes."${name}" =
        let
          cardano-devnet = import ./devnet.nix {
            inherit pkgs;
            inherit (config)
              devnetDirectory
              networkMagic
              initialFunds
              ;
            cardano-node = config.package;
          };

        in
        {
          command = cardano-devnet;
          readiness_probe = {
            exec.command = ''
              ${config.cardano-cli}/bin/cardano-cli query tip \
              --socket-path ${config.devnetDirectory}/node.socket \
              --testnet-magic ${builtins.toJSON config.networkMagic}'';
            initial_delay_seconds = 1;
            period_seconds = 1;
          };
        };
    };
in
{
  options = {
    services.cardano-devnet = lib.mkOption {
      description = ''
        cardano-devnet service
      '';
      default = { };
      type = lib.types.attrsOf (
        lib.types.submoduleWith {
          specialArgs = { inherit pkgs; };
          modules = [
            serviceModule
            mod
          ];
        }
      );
    };
  };
  config = {
    settings = {
      imports = lib.pipe config.services.cardano-devnet [
        (lib.filterAttrs (_: cfg: cfg.enable))
        (lib.mapAttrsToList (_: cfg: cfg.outputs.settings))
      ];
    };
  };
}
