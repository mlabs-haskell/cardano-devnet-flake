# Process-compose module

[Process-compose](https://f1bonacc1.github.io/process-compose/) is a utility to
orchestrate multiple processes, similarly to the way docker-compose does this
with docker containers. Process-compose handles configuring health checks,
dependencies between processes, retries, etc.

[Process-compose-flake](https://community.flake.arts/process-compose-flake)
wraps the above utiliy to integrate it with Nix, using flake-parts.

This process-compose module was built based on
[services-flake](https://github.com/juspay/services-flake/tree/main/nix/services),
following the same conventions where possible. Cardano devnet is compatible with
services-flake, you can use mix services from both in one configuration.

## Setup

In your `flake.nix`, you will have to include the following inputs:

```nix
inputs = {
  cardano-devnet.url = "github:mlabs-haskell/cardano-devnet-flake";
  flake-parts.follows = "cardano-devnet/flake-parts";

  # We will need to include process-compose-flake
  process-compose.url = "github:Platonic-Systems/process-compose-flake";

  # Use the cardano-node required by your project
  cardano-node.url = "github:IntersectMBO/cardano-node/10.1.4";
  # Use any nixpkgs version (following cardano-node will reduce dependencies)
  nixpkgs.follows = "cardano-node/nixpkgs";
};
```

Then, we will need to make a flake with `flake-parts` and import the
process-compose flake module. See the
[flake-parts documentation](https://flake.parts) for other configuration options.

```nix
flake-parts.lib.mkFlake { inherit inputs; } {
  imports = [
    inputs.process-compose.flakeModule
  ];
}
```

After this, we can setup a process-compose. This is where we can import the
cardano-devnet process compose module, and add the devnet configuration under
`services.cardano-devnet`.

See the cardano-devnet options [here](./options).

```nix
process-compose."process-compose-example" = {
  imports = [
    inputs.cardano-devnet.processComposeModule
  ];

  services.cardano-devnet."devnet" = {
    inherit (inputs.cardano-node.packages.${system}) cardano-node cardano-cli;
    enable = true;
    initialFunds = {
      "9783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
    };
  };
};
```

Now we can add the process-compose executable to our devShell:

```nix
devShells.default = pkgs.mkShell {
  nativeBuildInputs = [
    self'.packages."process-compose-example"
  ];
};
```

See an example setup [here](https://github.com/mlabs-haskell/cardano-devnet-flake/blob/main/example/process-compose-module/flake.nix).
