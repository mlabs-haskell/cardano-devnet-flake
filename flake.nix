{
  description = "Local Cardano devnet";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs";
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

      flake = {
        flakeModule = ./flake-module.nix;
        processComposeModule = ./process-compose-module.nix;
      };

      perSystem =
        { pkgs, lib, ... }:
        {
          packages = {
            documentation =
              let
                eval = lib.evalModules { modules = [ ./options.nix ]; };
                opts = pkgs.nixosOptionsDoc { options = eval.options.cardano-devnet; };
              in
              pkgs.stdenv.mkDerivation {
                name = "docs";
                src = ./docs;
                nativeBuildInputs = [ pkgs.mkdocs ];
                buildPhase = ''
                  cat ${opts.optionsCommonMark} >> "./src/options.md"
                  mkdocs build
                '';

                installPhase = ''
                  mv site $out
                '';
              };
          };
        };
    };
}
