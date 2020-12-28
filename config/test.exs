use Mix.Config

config :logger, backends: [{LoggerFileBackend, :file_log}]
config :logger, :file_log, path: "./log/#{Mix.env()}.log", metadata: [:blockchain_id]

if System.get_env("DEBUG") == "true" do
  config :logger, :file_log, level: :debug
else
  config :logger, :file_log, level: :info
end

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
