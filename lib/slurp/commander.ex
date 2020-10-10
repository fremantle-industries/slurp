defmodule Slurp.Commander do
  use GenServer
  alias Slurp.Blockchains

  @type blockchain :: Blockchains.Blockchain.t()
  @type opt_node :: {:node, {module, atom}}
  @type opt_store :: {:store_id, atom}
  @type opt_filter :: {:filters, list}

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec blockchains([opt_node | opt_store | opt_filter]) :: [blockchain]
  def blockchains(opts) do
    opts |> to_dest() |> GenServer.call({:blockchains, opts})
  end

  @spec start_blockchains([opt_node | opt_store | opt_filter]) ::
          {started :: non_neg_integer(), started_already :: non_neg_integer()}
  def start_blockchains(opts) do
    opts |> to_dest() |> GenServer.call({:start_blockchains, opts})
  end

  @spec stop_blockchains([opt_node | opt_store | opt_filter]) ::
          {stopped :: non_neg_integer(), stopped_already :: non_neg_integer()}
  def stop_blockchains(opts) do
    opts |> to_dest() |> GenServer.call({:stop_blockchains, opts})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:blockchains, opts}, _from, state) do
    store_id = Keyword.get(opts, :store_id, Blockchains.BlockchainStore.default_store_id())
    blockchains = Blockchains.all(store_id)
    {:reply, blockchains, state}
  end

  def handle_call({:start_blockchains, opts}, _from, state) do
    store_id = Keyword.get(opts, :store_id, Blockchains.BlockchainStore.default_store_id())
    filters = Keyword.get(opts, :filters, [])

    {started, started_already} =
      store_id
      |> Blockchains.all()
      |> Enumerati.filter(filters)
      |> Enum.map(& &1.id)
      |> Enum.reduce(
        {0, 0},
        fn blockchain_id, {started, started_already} ->
          case Slurp.Blockchains.ConnectionSupervisor.start_connection(blockchain_id) do
            {:ok, _pid} ->
              {started + 1, started_already}

            {:ok, _pid, _info} ->
              {started + 1, started_already}

            {:error, {:already_started, _pid}} ->
              {started, started_already + 1}

            _ ->
              {started, started_already}
          end
        end
      )

    {:reply, {started, started_already}, state}
  end

  def handle_call({:stop_blockchains, opts}, _from, state) do
    store_id = Keyword.get(opts, :store_id, Blockchains.BlockchainStore.default_store_id())
    filters = Keyword.get(opts, :filters, [])

    {stopped, stopped_already} =
      store_id
      |> Blockchains.all()
      |> Enumerati.filter(filters)
      |> Enum.map(& &1.id)
      |> Enum.reduce(
        {0, 0},
        fn blockchain_id, {stopped, stopped_already} ->
          case Slurp.Blockchains.ConnectionSupervisor.terminate_connection(blockchain_id) do
            :ok ->
              {stopped + 1, stopped_already}

            _ ->
              {stopped, stopped_already + 1}
          end
        end
      )

    {:reply, {stopped, stopped_already}, state}
  end

  defp to_dest(options) do
    options
    |> Keyword.get(:node)
    |> case do
      nil -> __MODULE__
      node -> {__MODULE__, node}
    end
  end
end
