defmodule Slurp.Commander.StopBlockchains do
  alias Slurp.Blockchains

  @spec stop_blockchains(list) ::
          {started :: non_neg_integer, stopped_already :: non_neg_integer}
  def stop_blockchains(opts) do
    store_id = Keyword.get(opts, :store_id, Blockchains.BlockchainStore.default_store_id())
    filters = Keyword.get(opts, :where, [])

    store_id
    |> Blockchains.all()
    |> Enumerati.filter(filters)
    |> Enum.map(& &1.id)
    |> Enum.reduce(
      {0, 0},
      fn blockchain_id, {stopped, stopped_already} ->
        case Slurp.ConnectionsSupervisor.terminate_connection(blockchain_id) do
          :ok ->
            {stopped + 1, stopped_already}

          _ ->
            {stopped, stopped_already + 1}
        end
      end
    )
  end
end
