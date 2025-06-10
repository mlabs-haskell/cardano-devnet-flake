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
      options = import ./options.nix { inherit lib pkgs; };

      config.outputs.settings.processes."${name}" =
        let
          cardano-devnet = import ./devnet.nix {
            inherit pkgs;
            inherit (config)
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
          command = cardano-devnet;
          readiness_probe = {
            exec.command = ''
              ${config.cardano-cli}/bin/cardano-cli query tip \
              --socket-path ${config.dataDir}/node.socket \
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
