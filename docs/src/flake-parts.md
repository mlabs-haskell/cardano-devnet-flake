# Flake parts module

Using the flake parts module is simpler, but only allows one configuration in
your flake. This configuration is recommended for simple applications and I
would recommend trying the process-compose module to setup a more robust
development environment.

## Setup

In your `flake.nix`, you will have to include the following inputs:

```nix
inputs = {
  cardano-devnet.url = "github:mlabs-haskell/cardano-devnet-flake";
  flake-parts.follows = "cardano-devnet/flake-parts";

  # Use the cardano-node required by your project
  cardano-node.url = "github:IntersectMBO/cardano-node/10.4.1";
  # Use any nixpkgs version (following cardano-node will reduce dependencies)
  nixpkgs.follows = "cardano-node/nixpkgs";
};
```

Then, we will need to make a flake with `flake-parts` and import the
cardano-devnet flake module. See the
[flake-parts documentation](https://flake.parts) for other configuration options.

```nix
flake-parts.lib.mkFlake { inherit inputs; } {
  imports = [
    inputs.cardano-devnet.flakeModule
  ];
```

Finally in the `perSystem`, we will add our cardano devnet configuration. See
the cardano-devnet options [here](./options).

With this done, the devnet will be exposed under `config.packages.cardano-devnet`,
but it makes sense to add this to the devShell so we can execute it from the nix
environment.

```nix
perSystem =
  {
    pkgs,
    config,
    system,
    ...
  }:
  {
    cardano-devnet = {
      inherit (inputs'.cardano-node.packages) cardano-node cardano-cli;
      initialFunds = {
        "9783be7d3c54f11377966dfabc9284cd6c32fca1cd42ef0a4f1cc45b" = 900000000000;
      };
    };

    devShells.default = pkgs.mkShell {
      buildInputs = [
        config.packages.cardano-devnet
      ];
    };
  };
```

Now we can run `nix develop .` and inside the dev shell, and execute
`cardano-devnet` to start up the network.

See an example setup [here](https://github.com/mlabs-haskell/cardano-devnet-flake/blob/main/example/flake-module/flake.nix).
