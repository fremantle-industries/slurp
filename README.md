# Slurp

[![Build Status](https://github.com/fremantle-industries/slurp/workflows/test/badge.svg?branch=main)](https://github.com/fremantle-industries/slurp/actions?query=workflow%3Atest)
[![hex.pm version](https://img.shields.io/hexpm/v/slurp.svg?style=flat)](https://hex.pm/packages/slurp)

An EVM block ingestion toolkit for Elixir

[Install](#install) | [Usage](#usage) | [Commands](./docs/COMMANDS.md) | [Configuration](./docs/CONFIGURATION.md)

## What Can I Do? TLDR;

Stream blocks & events from multiple EVM blockchains with a near-uniform API

| Supported Blockchains |
| --------------------- |
| Ethereum              |
| Ethereum Classic      |
| Binance Smart Chain   |
| Matic                 |
| Optimism              |
| NEAR                  |
| xDAI                  |

[![asciicast](https://asciinema.org/a/382198.svg)](https://asciinema.org/a/382198)

## Install

`slurp` requires Elixir 1.11+ & Erlang/OTP 22+. Add `slurp` to your list of dependencies in `mix.exs`

```elixir
def deps do
  [
    {:slurp, "~> 0.0.6"}
  ]
end
```

Create an `.iex.exs` file in the root of your project and import the `slurp` helper

```elixir
# .iex.exs
Application.put_env(:elixir, :ansi_enabled, true)

import Slurp.IEx
```

## Usage

`slurp` runs as an OTP application.

During development we can leverage `mix` to compile and run our application with an
interactive Elixir shell that imports the set of `slurp` helper [commands](./docs/COMMANDS.md).

```bash
iex -S mix
```

## Chain Details

[https://chainid.network/](https://chainid.network) maintains a list of EVM compatible blockchains including available [RPC providers](https://chainid.network/chains.json).

## Authors

- Alex Kwiatkowski - alex+git@fremantle.io

## License

`slurp` is released under the [MIT license](./LICENSE.md)
