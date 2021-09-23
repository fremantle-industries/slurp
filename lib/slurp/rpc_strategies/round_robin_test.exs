defmodule Slurp.RpcStrategyAdapter.RoundRobinTest do
  use ExUnit.Case, async: false

  import Mock
  import TestSupport.Blockchains, only: [put_blockchain: 2]

  alias Slurp.RpcStrategyAdapter.RoundRobin
  alias Slurp.RpcAgent

  @test_store_id __MODULE__
  @blockchain_id "test-chain"

  setup do
    start_supervised!({Slurp.Blockchains.BlockchainStore, id: @test_store_id})

    {:ok, _} =
      put_blockchain(
        %{
          id: @blockchain_id,
          name: "Test Mainnet",
          network_id: 1,
          chain_id: 1,
          chain: "TEST",
          testnet: false,
          rpc: [
            "https://mainnet.infura.io/v3/${INFURA_API_KEY}",
            "wss://mainnet.infura.io/ws/v3/${INFURA_API_KEY}",
            "https://api.mycryptoapi.com/eth",
            "https://cloudflare-eth.com"
          ],
          rpc_strategy: {RoundRobin, [threshold: 3, period: 1, unit: :minute]}
        },
        @test_store_id
      )

    {:ok, blockchain} = Slurp.Blockchains.BlockchainStore.find(@blockchain_id, @test_store_id)
    {:ok, %{blockchain: blockchain}}
  end

  test "round robin endpoint remains over threshold", %{blockchain: blockchain} do
    {:ok, time_state} = Agent.start_link(fn -> 0 end, name: __MODULE__)
    start_supervised!({RpcAgent, blockchain: blockchain})

    with_mock DateTime, [:passthrough],
      to_unix: fn _ -> Agent.get_and_update(time_state, fn state -> {state, state + 60} end) end do
      {:ok, endpoint} = RpcAgent.endpoint(blockchain)
      for i <- 0..4, i > 0, do: assert(:ok == RpcAgent.report_error(blockchain, :foo))
      assert {:ok, endpoint} == RpcAgent.endpoint(blockchain)
    end
  end

  test "round robin rotates to next endpoint when under threshold", %{blockchain: blockchain} do
    {:ok, time_state} = Agent.start_link(fn -> 0 end, name: __MODULE__)

    with_mock DateTime, [:passthrough],
      to_unix: fn _ -> Agent.get_and_update(time_state, fn state -> {state, state + 5} end) end do
      agent = start_supervised!({RpcAgent, blockchain: blockchain})

      {:ok, endpoint} = RpcAgent.endpoint(blockchain)
      for i <- 0..3, i > 0, do: assert(:ok == RpcAgent.report_error(blockchain, :foo))
      assert endpoint != RpcAgent.endpoint(blockchain)

      state = Agent.get(agent, & &1)
      assert state.buffer.size == 0
      assert List.last(state.endpoints) == endpoint
    end
  end
end
