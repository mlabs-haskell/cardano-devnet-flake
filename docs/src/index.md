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

This repository provides two ways to setup a cardano dev network, either as a
flake-parts module, or a process-compose module. The former is simpler, which
might be just enough for your use case, but I would recommend using the
process-compose module, which allows you to configure a full development
environment, similar to docker-compose.

- [Flake parts module](./flake-parts)
- [Process-compose module](./process-compose)
