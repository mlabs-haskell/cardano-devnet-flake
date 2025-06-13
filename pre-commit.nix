{ inputs, ... }:
{
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    { pkgs, config, ... }:
    {
      pre-commit.settings.hooks = {
        nixfmt-rfc-style.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        markdownlint.enable = true;
      };
      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.installationScript}
          echo 1>&2 "Welcome to the development shell!"
        '';
      };
    };
}
