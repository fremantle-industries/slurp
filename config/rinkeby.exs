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
    "ethereum-rinkeby" => %{
      start_on_boot: true,
      name: "Ethereum rinkeby",
      adapter: Slurp.Adapters.Evm,
      network_id: 4,
      chain_id: 1,
      chain: "ETH",
      testnet: true,
      timeout: 5000,
      new_head_initial_history: 128,
      poll_interval_ms: 2_500,
      rpc: [
        "https://rinkeby-light.eth.linkpool.io"
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


config :slurp,
  log_subscriptions: %{
    "*" => %{
      # ERC20
      {"Approval(address,address,uint256)",
      ["0xaFF4481D10270F50f203E0763e2597776068CBc5",
       "0x022E292b44B5a146F2e8ee36Ff44D3dd863C915c",
       "0xc6fDe3FD2Cc2b173aEC24cc3f267cb3Cd78a26B7",
       "0x1f9061B953bBa0E36BF50F21876132DcF276fC6e"]} => [
        %{
          enabled: true,
          struct: Examples.Erc20.Events.Approval,
          handler: {Examples.EventHandler, :handle_erc20_approval, []},
          abi: [
            %{
              "anonymous" => false,
              "inputs" => [
                %{
                  "indexed" => true,
                  "name" => "owner",
                  "type" => "address"
                },
                %{
                  "indexed" => true,
                  "name" => "spender",
                  "type" => "address"
                },
                %{
                  "indexed" => false,
                  "name" => "value",
                  "type" => "uint256"
                }
              ],
              "name" => "Approval",
              "type" => "event"
            }
          ]
        }
      ]
    }
  }
