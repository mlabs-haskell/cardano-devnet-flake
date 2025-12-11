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
            evalCardanoDevnet = lib.evalModules { modules = [ ./modules/cardano-devnet/options.nix ]; };
            cardanoDevnetOpts = pkgs.nixosOptionsDoc { options = evalCardanoDevnet.options.cardano-devnet; };

            evalHydraNode = lib.evalModules { modules = [ ./modules/hydra-node/options.nix ]; };
            hydraNodeOpts = pkgs.nixosOptionsDoc { options = evalHydraNode.options.hydra-node; };
          in
          pkgs.stdenv.mkDerivation {
            name = "docs";
            src = ./docs;
            nativeBuildInputs = [ pkgs.mkdocs ];
            buildPhase = ''
              mkdir src/cardano-devnet
              mkdir src/hydra-node
              cat ${cardanoDevnetOpts.optionsCommonMark} >> "./src/cardano-devnet/options.md"
              cat ${hydraNodeOpts.optionsCommonMark} >> "./src/hydra-node/options.md"
              mkdocs build
            '';

            installPhase = ''
              mv site $out
            '';
          };
      };

    };

}
