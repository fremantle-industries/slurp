defmodule Slurp.IEx.Commands.StopBlockchainsTest do
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

    assert capture_io(fn -> Slurp.IEx.stop_blockchains(store_id: @test_store_id) end) ==
             "Stopped blockchains: 0 new, 2 already stopped\n"

    assert capture_io(fn -> Slurp.IEx.start_blockchains(store_id: @test_store_id) end) ==
             "Started blockchains: 2 new, 0 already running\n"

    assert capture_io(fn -> Slurp.IEx.stop_blockchains(store_id: @test_store_id) end) ==
             "Stopped blockchains: 2 new, 0 already stopped\n"

    # output = capture_io(fn -> Slurp.IEx.blockchains(store_id: @test_store_id) end)
    # assert output =~ ~r/\|\s+group_a \|\s+main \|\s+running \|\s+#PID<.+> \|/
    # assert output =~ ~r/\|\s+group_b \|\s+main \|\s+running \|\s+#PID<.+> \|/
  end
end
