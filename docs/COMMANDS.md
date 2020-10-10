# Commands

[Install](../README.md#install) | [Usage](../README.md#usage) | [Commands](./COMMANDS.md)

To monitor your instance, `slurp` provides the following set of IEx commands.

## help

Display the available commands and usage examples

```
iex(1)> help
* help
* blockchains [where: [...], order: [...]]
* start_blockchains [where: [...]
* stop_blockchains [where: [...]
```

## blockchains

List blockchains that can optionally be filtered and ordered

```
iex(2)> blockchains
+------------------+--------------------------+------------+----------+-------+---------+----------------------------------------------------------+
|               ID |                     Name | Network ID | Chain ID | Chain | Testnet |                                                      RPC |
+------------------+--------------------------+------------+----------+-------+---------+----------------------------------------------------------+
| ethereum-mainnet |         Ethereum Mainnet |          1 |        1 |   ETH |   false | https://mainnet.infura.io/v3/${INFURA_API_KEY}, (3 more) |
| ethereum-ropsten | Ethereum Testnet Ropsten |          3 |        3 |   ETH |    true | https://ropsten.infura.io/v3/${INFURA_API_KEY}, (1 more) |
+------------------+--------------------------+------------+----------+-------+---------+----------------------------------------------------------+
```
