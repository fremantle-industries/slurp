defmodule Slurp.Commander do
  use GenServer
  alias __MODULE__
  alias Slurp.{Blockchains, NewHeads, Logs}

  @type blockchain :: Blockchains.Blockchain.t()
  @type new_head_subscription :: NewHeads.NewHeadSubscription.t()
  @type log_subscription :: Logs.LogSubscription.t()
  @type opt_node :: {:node, {module, atom}}
  @type opt_store :: {:store_id, atom}
  @type opt_where :: {:where, list}
  @type opt_order :: {:order, list}

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec blockchains([opt_node | opt_store | opt_where | opt_order]) :: [blockchain]
  def blockchains(opts) do
    opts |> to_dest() |> GenServer.call({:blockchains, opts})
  end

  @spec start_blockchains([opt_node | opt_store | opt_where]) ::
          {started :: non_neg_integer(), started_already :: non_neg_integer()}
  def start_blockchains(opts) do
    opts |> to_dest() |> GenServer.call({:start_blockchains, opts})
  end

  @spec stop_blockchains([opt_node | opt_store | opt_where]) ::
          {stopped :: non_neg_integer(), stopped_already :: non_neg_integer()}
  def stop_blockchains(opts) do
    opts |> to_dest() |> GenServer.call({:stop_blockchains, opts})
  end

  @spec new_head_subscriptions([opt_node | opt_store | opt_where | opt_order]) :: [
          new_head_subscription
        ]
  def new_head_subscriptions(opts) do
    opts |> to_dest() |> GenServer.call({:new_head_subscriptions, opts})
  end

  @spec log_subscriptions([opt_node | opt_store | opt_where | opt_order]) :: [log_subscription]
  def log_subscriptions(opts) do
    opts |> to_dest() |> GenServer.call({:log_subscriptions, opts})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:blockchains, opts}, _from, state) do
    blockchains = Commander.Blockchains.list(opts)
    {:reply, blockchains, state}
  end

  def handle_call({:start_blockchains, opts}, _from, state) do
    {started, started_already} = Commander.StartBlockchains.start_blockchains(opts)
    {:reply, {started, started_already}, state}
  end

  def handle_call({:stop_blockchains, opts}, _from, state) do
    {stopped, stopped_already} = Commander.StartBlockchains.stop_blockchains(opts)
    {:reply, {stopped, stopped_already}, state}
  end

  @log_subscriptions_default_order ~w(blockchain_id event_signature)a
  def handle_call({:log_subscriptions, opts}, _from, state) do
    order_by = Keyword.get(opts, :order, @log_subscriptions_default_order)
    filters = Keyword.get(opts, :where, [])
    store_id = Keyword.get(opts, :store_id, Logs.LogSubscriptionStore.default_store_id())

    log_subscriptions =
      store_id
      |> Slurp.Logs.Subscriptions.all()
      |> Enumerati.filter(filters)
      |> Enumerati.order(order_by)

    {:reply, log_subscriptions, state}
  end

  @new_head_subscriptions_default_order ~w(blockchain_id)a
  def handle_call({:new_head_subscriptions, opts}, _from, state) do
    order_by = Keyword.get(opts, :order, @new_head_subscriptions_default_order)

    new_head_subscriptions =
      opts
      |> NewHeads.Subscriptions.all()
      |> Enumerati.order(order_by)

    {:reply, new_head_subscriptions, state}
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
