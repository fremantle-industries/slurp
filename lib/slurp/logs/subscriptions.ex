defmodule Slurp.Logs.Subscriptions do
  alias Slurp.{Blockchains, Logs}

  @type blockchain :: Blockchains.Blockchain.t()
  @type blockchain_id :: Blockchains.Blockchain.id()
  @type log_subscription :: Logs.LogSubscription.t()
  @type log_subscription_store_id :: Logs.LogSubscriptionStore.store_id()
  @type invalid_config :: String.t()

  @spec from_config([blockchain]) :: {:ok, [log_subscription]} | {:error, invalid_config}
  def from_config(blockchains) do
    from_config(blockchains, Application.get_env(:slurp, :log_subscriptions, %{}))
  end

  @spec from_config([blockchain], map) :: {:ok, [log_subscription]} | {:error, invalid_config}
  def from_config(blockchains, config) when is_map(config) do
    keyed_blockchains =
      blockchains
      |> Enum.reduce(
        %{},
        fn blockchain, acc -> Map.put(acc, blockchain.id, blockchain) end
      )

    log_subscriptions =
      config
      |> Enum.flat_map(fn {blockchains_query, events} ->
        keyed_blockchains
        |> Juice.squeeze(blockchains_query)
        |> Enum.flat_map(fn {blockchain_id, blockchain} ->
          events
          |> Enum.flat_map(fn {event_signature, handlers} ->
            handlers
            |> Enum.map(fn handler ->
              hashed_event_signature =
                Slurp.Adapter.hash_event_signature(blockchain, event_signature)

              attrs =
                Map.merge(handler, %{
                  blockchain_id: blockchain_id,
                  event_signature: event_signature,
                  hashed_event_signature: hashed_event_signature
                })

              struct!(Logs.LogSubscription, attrs)
            end)
          end)
        end)
      end)

    {:ok, log_subscriptions}
  end

  def from_config(_blockchains, config) do
    {:error,
     "invalid env :log_subscriptions for application :slurp. #{inspect(config)} is not a map"}
  end

  @spec all :: [log_subscription]
  @spec all(log_subscription_store_id) :: [log_subscription]
  def all(store_id \\ Logs.LogSubscriptionStore.default_store_id()) do
    Logs.LogSubscriptionStore.all(store_id)
  end

  @spec query(list) :: [log_subscription]
  def query(filters) do
    store_id = Keyword.get(filters, :store_id, Logs.LogSubscriptionStore.default_store_id())

    Keyword.delete(filters, :store_id)

    store_id
    |> Logs.LogSubscriptionStore.all()
    |> Enumerati.filter(filters)
  end

  @spec put(log_subscription) :: {:ok, {term, log_subscription}}
  @spec put(log_subscription, log_subscription_store_id) :: {:ok, {term, log_subscription}}
  def put(log_subscription, store_id \\ Logs.LogSubscriptionStore.default_store_id()) do
    Logs.LogSubscriptionStore.put(log_subscription, store_id)
  end
end
