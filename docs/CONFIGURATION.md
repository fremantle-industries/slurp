# Configuration

[Built with Slurp](./BUILT_WITH_SLURP.md) | [Install](#install) | [Usage](#usage) | [Commands](./COMMANDS.md) | [Configuration](./CONFIGURATION.md)

Use the [example dev configuration](../config/runtime.exs#L18) to get started.

## Global

`slurp` is configured with standard [Elixir](https://elixir-lang.org/getting-started/mix-otp/config-and-releases.html)
constructs under the `:slurp` key. Details for each configuration option are provided below:

```elixir
# [default: %{}] [optional] Map of configured advisor groups. See below for more details.
config :slurp, blockchains: %{}

# [default: %{}] [optional] Map of configured advisor groups. See below for more details.
config :slurp, log_subscriptions: %{}
```

## Blockchains

`blockchains` abstract a common interface for subscribing and requesting data.
They are configured under the `:slurp, :blockchains` key.

```elixir
config :slurp,
  blockchains: %{
    "ethereum-mainnet" => [
      # [default: true] [optional] Starts the blockchain on initial boot
      start_on_boot: true
    ]
  }
```

## New Head Subscriptions

`new_head_subscriptions` abstract a common interface for streaming incoming blocks. They
are configured under the `:slurp, :new_head_subscriptions` key.

```elixir
config :slurp,
  new_head_subscriptions: %{
    "*" => [
      %{
        enabled: true,
        handler: {Examples.NewHeadHandler, :handle_new_head, []}
      }
    ]
  }
```

## Log Subscriptions

`log_subscriptions` abstract a common interface for scanning events emitted
from contracts. They are configured under the `:slurp, :log_subscriptions` key.

They can be configured in 2 ways:
1. **explicit config map** - A map containing keys of event signatures and a list decode handlers
2. **mfa** - A module, function, arguments tuple that returns an explicit config map from (1)

```elixir
config :slurp,
  log_subscriptions: %{
    "ethereum-mainnet" => %{
      # ERC20
      "Transfer(address,address,uint256)" => [
        %{
          enabled: true,
          struct: Examples.Erc20.Events.Transfer,
          handler: {Examples.EventHandler, :handle_erc20_transfer, []},
          abi: [
            %{
              "anonymous" => false,
              "inputs" => [
                %{
                  "indexed" => true,
                  "name" => "from",
                  "type" => "address"
                },
                %{
                  "indexed" => true,
                  "name" => "to",
                  "type" => "address"
                },
                %{
                  "indexed" => false,
                  "name" => "value",
                  "type" => "uint256"
                }
              ],
              "name" => "Transfer",
              "type" => "event"
            }
          ]
        }
      ]
    },
    "*" => [
      {Examples.Erc20.EventFactory, :create, [[approval_enabled: true, transfer_enabled: true]]}
    ]
  }
```

## Logging

By default Elixir will use the console logger to print logs to `stdout` in the
main process running `slurp`. You can configure your Elixir logger to format
or change the location of the output.

For example. To write to a file, add a file logger:

```elixir
# mix.exs
defp deps do
  {:logger_file_backend, "~> 0.0.10"}
end
```

And configure it's log location:

```elixir
# config/config.exs
use Mix.Config

config :logger, :file_log, path: "./log/#{Mix.env()}.log"
config :logger, backends: [{LoggerFileBackend, :file_log}]
```

If you intend to deploy `slurp` to a service that ingests structured logs, you
will need to use a supported backed. For Google Cloud Stackdriver you can use `logger_json`

```elixir
# mix.exs
defp deps do
  {:logger_json, "~> 2.0.1"}
end

# config/config.exs
use Mix.Config

config :logger_json, :backend, metadata: :all
config :logger, backends: [LoggerJSON]
```
