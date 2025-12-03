{ inputs, ... }:
{
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    { config, ... }:
    {
      pre-commit.settings.hooks = {
        nixfmt-rfc-style.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        markdownlint.enable = true;
      };
      devShells.default = config.pre-commit.devShell;
    };
}
