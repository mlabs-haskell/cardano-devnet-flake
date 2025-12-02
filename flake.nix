{
  description = "Local Cardano devnet";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    hci-effects.url = "github:hercules-ci/hercules-ci-effects";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [
        ./hercules-ci.nix
        ./documentation.nix
        ./pre-commit.nix
      ];

      flake = {
        flakeModule = ./flake-module.nix;
        processComposeModule = ./process-compose-module.nix;
      };
    };
}
