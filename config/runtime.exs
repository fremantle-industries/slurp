import Config

config :slurp, blockchains: %{}
config :slurp, new_head_subscriptions: %{}
config :slurp, log_subscriptions: %{}

config :logger, backends: [{LoggerFileBackend, :file_log}]
config :logger, :file_log, path: "./log/#{config_env()}.log", metadata: [:blockchain_id]

if System.get_env("DEBUG") == "true" do
  config :logger, :file_log, level: :debug
else
  config :logger, :file_log, level: :info
end

# Conditional configuration
# dev
if config_env() == :dev do
  config :slurp,
    blockchains: %{
      "ethereum-mainnet" => %{
        start_on_boot: false,
        name: "Ethereum Mainnet",
        adapter: Slurp.Adapters.Evm,
        network_id: 1,
        chain_id: 1,
        chain: "ETH",
        testnet: false,
        timeout: 5000,
        new_head_initial_history: 1,
        poll_interval_ms: 2_500,
        explorer: {Slurp.ExplorerAdapters.Etherscan, "https://etherscan.io"},
        rpc: [
          # "https://cloudflare-eth.com" # On initial get_logs() this returns logs that don't match a subscription???
          "https://api.mycryptoapi.com/eth"
        ]
      },
      "binance-smart-chain-mainnet" => %{
        start_on_boot: false,
        name: "Binance Smart Chain Mainnet",
        adapter: Slurp.Adapters.Evm,
        network_id: 56,
        chain_id: 56,
        chain: "BSC",
        testnet: false,
        timeout: 5000,
        new_head_initial_history: 1,
        poll_interval_ms: 1_000,
        explorer: {Slurp.ExplorerAdapters.BscScan, "https://bscscan.com"},
        rpc: [
          "https://bsc-dataseed1.binance.org"
        ]
      },
      "avalanche-mainnet" => %{
        start_on_boot: false,
        name: "Avalanche Mainnet",
        adapter: Slurp.Adapters.Evm,
        network_id: 43114,
        chain_id: 43114,
        chain: "Avax",
        testnet: false,
        timeout: 5000,
        new_head_initial_history: 1,
        poll_interval_ms: 2_500,
        explorer: {Slurp.ExplorerAdapters.Avascan, "https://avascan.info"},
        rpc: [
          "https://api.avax.network/ext/bc/C/rpc"
        ]
      }
    }

  config :slurp,
    new_head_subscriptions: %{
      "*" => [
        %{
          enabled: true,
          handler: {Examples.NewHeadHandler, :handle_new_head, []}
        }
      ]
    }

  # Log subscriptions can be configured in 2 ways:
  # 1. explicit config map - A map containing keys of event signatures and a list decode handlers
  # 2. mfa - A module, function, arguments tuple that returns an explicit config map from (1)
  config :slurp,
    log_subscriptions: %{
      "*" => [
        {Examples.Tokens.EventFactory, :create, [[approval_enabled: true, transfer_enabled: true]]}
      ],
      "ethereum-mainnet" => %{
        # UniswapV2
        "Swap(address,uint256,uint256,uint256,uint256,address)" => [
          %{
            enabled: true,
            handler: {Examples.EventHandler, :handle_uniswap_v2_swap, []},
            event_mappings: [
              {
                Examples.UniswapV2.Events.Swap,
                %{
                  "anonymous" => false,
                  "inputs" => [
                    %{
                      "indexed" => true,
                      "name" => "sender",
                      "type" => "address"
                    },
                    %{
                      "indexed" => false,
                      "name" => "amount0In",
                      "type" => "uint256"
                    },
                    %{
                      "indexed" => false,
                      "name" => "amount1In",
                      "type" => "uint256"
                    },
                    %{
                      "indexed" => false,
                      "name" => "amount0Out",
                      "type" => "uint256"
                    },
                    %{
                      "indexed" => false,
                      "name" => "amount1Out",
                      "type" => "uint256"
                    },
                    %{
                      "indexed" => true,
                      "name" => "to",
                      "type" => "address"
                    }
                  ],
                  "name" => "Swap",
                  "type" => "event"
                }
              }
            ]
          }
        ],
        "Sync(uint112,uint112)" => [
          %{
            enabled: true,
            handler: {Examples.EventHandler, :handle_uniswap_v2_sync, []},
            event_mappings: [
              {
                Examples.UniswapV2.Events.Sync,
                %{
                  "anonymous" => false,
                  "inputs" => [
                    %{
                      "indexed" => false,
                      "name" => "reserve0",
                      "type" => "uint112"
                    },
                    %{
                      "indexed" => false,
                      "name" => "reserve1",
                      "type" => "uint112"
                    }
                  ],
                  "name" => "Sync",
                  "type" => "event"
                }
              }
            ]
          }
        ]
      }
    }
end

# test
if config_env() == :test do
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
          "https://mainnet.infura.io/v3/${INFURA_API_KEY}",
          "wss://mainnet.infura.io/ws/v3/${INFURA_API_KEY}",
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
end
