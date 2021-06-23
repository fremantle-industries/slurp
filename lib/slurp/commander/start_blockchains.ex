defmodule Slurp.Commander.StartBlockchains do
  require Logger

  @spec start_blockchains(list) ::
          {started :: non_neg_integer, started_already :: non_neg_integer}
  def start_blockchains(opts) do
    store_id = Keyword.get(opts, :store_id, Blockchains.BlockchainStore.default_store_id())
    filters = Keyword.get(opts, :where, [])

    store_id
    |> Blockchains.all()
    |> Enumerati.filter(filters)
    |> Enum.map(& &1.id)
    |> Enum.reduce(
      {0, 0},
      fn blockchain_id, {started, started_already} ->
        case Slurp.ConnectionsSupervisor.start_connection(blockchain_id) do
          {:ok, _pid} ->
            {started + 1, started_already}

          {:ok, _pid, _info} ->
            {started + 1, started_already}

          {:error, {:already_started, _pid}} ->
            {started, started_already + 1}

          els ->
            Logger.error(inspect(els))
            {started, started_already}
        end
      end
    )
  end
end
