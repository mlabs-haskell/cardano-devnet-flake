_: {
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages = {
        documentation =
          let
            eval = lib.evalModules { modules = [ ./devnet/options.nix ]; };
            opts = pkgs.nixosOptionsDoc { options = eval.options.cardano-devnet; };
          in
          pkgs.stdenv.mkDerivation {
            name = "docs";
            src = ./docs;
            nativeBuildInputs = [ pkgs.mkdocs ];
            buildPhase = ''
              cat ${opts.optionsCommonMark} >> "./src/devnet/options.md"
              mkdocs build
            '';

            installPhase = ''
              mv site $out
            '';
          };
      };

    };

}
