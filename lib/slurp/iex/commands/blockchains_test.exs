defmodule Slurp.IEx.Commands.BlockchainsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import TestSupport.Blockchains, only: [put_blockchain: 2]

  @test_store_id __MODULE__

  setup do
    start_supervised!({Slurp.Blockchains.BlockchainStore, id: @test_store_id})
    :ok
  end

  test "shows all blockchains ordered id by default" do
    put_blockchain(
      %{
        id: "ethereum-mainnet",
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
      @test_store_id
    )

    put_blockchain(
      %{
        id: "ethereum-ropsten",
        name: "Ethereum Testnet Ropsten",
        network_id: 3,
        chain_id: 3,
        chain: "ETH",
        testnet: true,
        rpc: [
          "https://ropsten.infura.io/v3/${INFURA_API_KEY}",
          "wss://ropsten.infura.io/ws/v3/${INFURA_API_KEY}"
        ]
      },
      @test_store_id
    )

    assert capture_io(fn -> Slurp.IEx.blockchains(store_id: @test_store_id) end) == """
           +------------------+--------------------------+------------+----------+-------+---------+----------------------------------------------------------+
           |               ID |                     Name | Network ID | Chain ID | Chain | Testnet |                                                      RPC |
           +------------------+--------------------------+------------+----------+-------+---------+----------------------------------------------------------+
           | ethereum-mainnet |         Ethereum Mainnet |          1 |        1 |   ETH |   false | https://mainnet.infura.io/v3/${INFURA_API_KEY}, (3 more) |
           | ethereum-ropsten | Ethereum Testnet Ropsten |          3 |        3 |   ETH |    true | https://ropsten.infura.io/v3/${INFURA_API_KEY}, (1 more) |
           +------------------+--------------------------+------------+----------+-------+---------+----------------------------------------------------------+\n
           """
  end

  test "shows an empty table when there are no blockchains" do
    assert capture_io(fn -> Slurp.IEx.blockchains(store_id: @test_store_id) end) == """
           +----+------+------------+----------+-------+---------+-----+
           | ID | Name | Network ID | Chain ID | Chain | Testnet | RPC |
           +----+------+------------+----------+-------+---------+-----+
           |  - |    - |          - |        - |     - |       - |   - |
           +----+------+------------+----------+-------+---------+-----+\n
           """
  end
end
