use Mix.Config

config :logger,
  backends: [{LoggerFileBackendWithFormatters, :file_log}],
  utc_log: true

config :logger, :file_log, path: "./log/#{Mix.env()}.log"

if System.get_env("DEBUG") == "true" do
  config :logger, :file_log, level: :debug
else
  config :logger, :file_log, level: :info
end

# config :keeper, provider: Keeper.Vault
# config :keeper, provider: Keeper.AWS
# config :keeper, provider: Keeper.GCP
# config :keeper, provider: Keeper.Memory
# config :keeper, provider: Keeper.File

config :slurp, websocket_rpc_enabled: false
config :slurp, subscription_enabled: false

config :slurp,
  blockchains: %{
    "ethereum-mainnet" => %{
      start_on_boot: false,
      name: "Ethereum Mainnet",
      network_id: 1,
      chain_id: 1,
      chain: "ETH",
      testnet: false,
      rpc: [
        # "https://mainnet.infura.io/v3/${INFURA_API_KEY}",
        # "wss://mainnet.infura.io/ws/v3/${INFURA_API_KEY}",
        "https://api.mycryptoapi.com/eth",
        "https://cloudflare-eth.com"
      ]
    },
    "ethereum-ropsten" => %{
      start_on_boot: false,
      name: "Ethereum Testnet Ropsten",
      network_id: 3,
      chain_id: 3,
      chain: "ETH",
      testnet: true,
      rpc: [
        "https://ropsten.infura.io/v3/${INFURA_API_KEY}",
        "wss://ropsten.infura.io/ws/v3/${INFURA_API_KEY}"
      ]
    }
  }

config :slurp, new_heads_subscription_enabled: true
config :slurp, new_heads_subscription_handler: {Examples.NewHeads, :handle_new_head, []}

# config :slurp, log_event_subscription_enabled: true

# config :slurp,
#   log_event_subscriptions: %{
#     "balanceOf()" => [
#       %{
#         enabled: true,
#         blockchains: "*",
#         abi: [],
#         log_event: Examples.Events.LogEvents.BalanceOf,
#         handler: {Examples.Events, :handle_balance_of, []}
#       }
#     ],
#     "NewRound()" => [
#       %{
#         enabled: true,
#         blockchains: "*",
#         abi: [],
#         log_event: Examples.Events.LogEvents.NewRound,
#         handler: {Examples.Events, :handle_new_round, []}
#       }
#     ]
#   }

# config :slurp, transaction_subscription_enabled: true

# config :slurp,
#   transaction_subscription_handler: {Examples.Transactions, :handle_transaction, []}
