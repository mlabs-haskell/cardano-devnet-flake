{
  description = "Local Cardano devnet";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = _: {
    flakeModule = ./flake-module.nix;
    processComposeModule = ./process-compose-module.nix;
  };
}
