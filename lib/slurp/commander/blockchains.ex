defmodule Slurp.Commander.Blockchains do
  alias Slurp.{Stores, Subscriptions}

  defmodule ListItem do
    defstruct ~w(
      id
      name
      adapter
      network_id
      chain_id
      chain
      testnet
      start_on_boot
      timeout
      new_head_initial_history
      poll_interval_ms
      rpc
      status
    )a
  end

  @list_default_order ~w(id)a
  def list(opts) do
    store_id = Keyword.get(opts, :store_id, Stores.BlockchainStore.default_store_id())
    filters = Keyword.get(opts, :where, [])
    order_by = Keyword.get(opts, :order, @list_default_order)

    store_id
    |> Subscriptions.Blockchains.all()
    |> Enum.map(fn b ->
      %ListItem{
        id: b.id,
        name: b.name,
        adapter: b.adapter,
        network_id: b.network_id,
        chain_id: b.chain_id,
        chain: b.chain,
        testnet: b.testnet,
        start_on_boot: b.start_on_boot,
        timeout: b.timeout,
        new_head_initial_history: b.new_head_initial_history,
        poll_interval_ms: b.poll_interval_ms,
        rpc: b.rpc,
        status: status(b)
      }
    end)
    |> Enumerati.filter(filters)
    |> Enumerati.order(order_by)
  end

  defp status(blockchain) do
    blockchain.id
    |> Slurp.ConnectionSupervisor.process_name()
    |> Process.whereis()
    |> case do
      pid when is_pid(pid) -> :running
      _ -> :unstarted
    end
  end
end
