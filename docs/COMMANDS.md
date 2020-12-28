# Commands

[Install](../README.md#install) | [Usage](../README.md#usage) | [Commands](./COMMANDS.md) | [Configuration](./CONFIGURATION.md)

To control your instance `slurp` provides the following set of IEx commands.

## help

Display the available commands and usage examples

```
iex(1)> help
* help
* blockchains [where: [...], order: [...]]
* start_blockchains [where: [...]]
* stop_blockchains [where: [...]]
* new_head_subscriptions [where: [...], order: [...]]
* log_subscriptions [where: [...]]
```

## blockchains

List blockchains that can optionally be filtered and ordered

```
iex(2)> blockchains
+------------------+--------------------------+-----------+------------+----------+-------+---------+----------------------------------------------------------+
|               ID |                     Name |    Status | Network ID | Chain ID | Chain | Testnet |                                                      RPC |
+------------------+--------------------------+-----------+------------+----------+-------+---------+----------------------------------------------------------+
| ethereum-mainnet |         Ethereum Mainnet | unstarted |          1 |        1 |   ETH |   false | https://mainnet.infura.io/v3/${INFURA_API_KEY}, (3 more) |
| ethereum-ropsten | Ethereum Testnet Ropsten | unstarted |          3 |        3 |   ETH |    true | https://ropsten.infura.io/v3/${INFURA_API_KEY}, (1 more) |
+------------------+--------------------------+-----------+------------+----------+-------+---------+----------------------------------------------------------+
```

## start_blockchains

Starts blockchains with an optional filter

```
iex(3)> start_blockchains where: [id: "ethereum-mainnet"]
Started blockchains: 1 new, 0 already running
```

## stop_blockchains

Stops blockchains with an optional filter

```
iex(4)> stop_blockchains where: [id: "ethereum-mainnet"]
Stopped blockchains: 1 new, 0 already running
```

## new_head_subscriptions

List new head subscriptions that can optionally be filtered and ordered

```
iex(5)> new_head_subscriptions
+-----------------------------+---------+-------------------------------------------------+
|               Blockchain ID | Enabled |                                         Handler |
+-----------------------------+---------+-------------------------------------------------+
| binance-smart-chain-mainnet |    true | {Examples.NewHeadHandler, :handle_new_head, []} |
|            ethereum-mainnet |    true | {Examples.NewHeadHandler, :handle_new_head, []} |
+-----------------------------+---------+-------------------------------------------------+
```

## log_subscriptions

List log subscriptions that can optionally be filtered and ordered

```
iex(6)> log_subscriptions
+-----------------------------+-------------------------------------------+------------------------+---------+---------------------------------------+------------------------------------------------------+-----+
|               Blockchain ID |                           Event Signature | Hashed Event Signature | Enabled |                                Struct |                                              Handler | ABI |
+-----------------------------+-------------------------------------------+------------------------+---------+---------------------------------------+------------------------------------------------------+-----+
| binance-smart-chain-mainnet |         Approval(address,address,uint256) | 0x8c5be1e5ebec7d5bd... |   false | Elixir.Examples.Erc20.Events.Approval |  {Examples.EventHandler, :handle_erc20_approval, []} |   1 |
| binance-smart-chain-mainnet |           Burn(address,uint,uint,address) | 0x9997fadbe0b8ea492... |   false | Elixir.Examples.UniswapV2.Events.Burn | {Examples.EventHandler, :handle_uniswap_v2_burn, []} |   1 |
| binance-smart-chain-mainnet |                   Mint(address,uint,uint) | 0x92fc9586b1c52be04... |   false | Elixir.Examples.UniswapV2.Events.Mint | {Examples.EventHandler, :handle_uniswap_v2_mint, []} |   1 |
| binance-smart-chain-mainnet | Swap(address,uint,uint,uint,uint,address) | 0x6d5619a2e2e254d51... |   false | Elixir.Examples.UniswapV2.Events.Swap | {Examples.EventHandler, :handle_uniswap_v2_swap, []} |   1 |
| binance-smart-chain-mainnet |                     Sync(uint112,uint112) | 0x1c411e9a96e071241... |   false | Elixir.Examples.UniswapV2.Events.Sync | {Examples.EventHandler, :handle_uniswap_v2_sync, []} |   1 |
| binance-smart-chain-mainnet |         Transfer(address,address,uint256) | 0xddf252ad1be2c89b6... |    true | Elixir.Examples.Erc20.Events.Transfer |  {Examples.EventHandler, :handle_erc20_transfer, []} |   1 |
|            ethereum-mainnet |         Approval(address,address,uint256) | 0x8c5be1e5ebec7d5bd... |   false | Elixir.Examples.Erc20.Events.Approval |  {Examples.EventHandler, :handle_erc20_approval, []} |   1 |
|            ethereum-mainnet |           Burn(address,uint,uint,address) | 0x9997fadbe0b8ea492... |   false | Elixir.Examples.UniswapV2.Events.Burn | {Examples.EventHandler, :handle_uniswap_v2_burn, []} |   1 |
|            ethereum-mainnet |                   Mint(address,uint,uint) | 0x92fc9586b1c52be04... |   false | Elixir.Examples.UniswapV2.Events.Mint | {Examples.EventHandler, :handle_uniswap_v2_mint, []} |   1 |
|            ethereum-mainnet | Swap(address,uint,uint,uint,uint,address) | 0x6d5619a2e2e254d51... |   false | Elixir.Examples.UniswapV2.Events.Swap | {Examples.EventHandler, :handle_uniswap_v2_swap, []} |   1 |
|            ethereum-mainnet |                     Sync(uint112,uint112) | 0x1c411e9a96e071241... |   false | Elixir.Examples.UniswapV2.Events.Sync | {Examples.EventHandler, :handle_uniswap_v2_sync, []} |   1 |
|            ethereum-mainnet |         Transfer(address,address,uint256) | 0xddf252ad1be2c89b6... |    true | Elixir.Examples.Erc20.Events.Transfer |  {Examples.EventHandler, :handle_erc20_transfer, []} |   1 |
+-----------------------------+-------------------------------------------+------------------------+---------+---------------------------------------+------------------------------------------------------+-----+
```
