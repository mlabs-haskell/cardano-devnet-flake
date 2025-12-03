# Cardano Devnet

Cardano testnet for dApp development and testing locally.

---

This is a Nix based cardano devnet, that will allow you to run a single-node
testnet locally, and submit transactions to it just as any other testnet.

![demo](./img/demo.gif)

Benefits compared to other similar solutions:

- **language agnostic**: you can use your own transaction builder, indexer
  regardless of the programming language.
- **CI compatible**: use the same configuration on the CI to run your tests on a
  real network
- **fast**: due to its simplicity, spinning up a test network is really fast.
  If the slot length is configured to a small value, transactions will also
  finish quickly
- **no docker required**: the node runs as a local executable, which means that
  you can easily connect to its unix socket from other utilities (this has been
  a problem on MacOS with docker-based solutions)
- **works on Linux and MacOS** (haven't tested Windows WSL, but it should work
  there as well)

## How to use

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

### Setup

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

See the [cardano-devnet options](/cardano-devnet-flake/cardano-devnet/options) and [hydra-node options](/cardano-devnet-flake/hydra-node/options) pages for other
configuration options.

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

See an example setup at [./example/cardano-stack/flake.nix](https://github.com/mlabs-haskell/cardano-devnet-flake/blob/main/example/cardano-stack/flake.nix).
