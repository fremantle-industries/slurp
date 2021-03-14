defmodule Slurp.Subscriptions.NewHeads do
  alias Slurp.{Stores, Specs}

  @type blockchain :: Specs.Blockchain.t()
  @type new_head_subscription :: Specs.NewHeadSubscription.t()
  @type new_head_subscription_store_id :: Stores.NewHeadSubscriptionStore.store_id()
  @type invalid_config :: String.t()

  @spec from_config([blockchain]) :: {:ok, [new_head_subscription]} | {:error, invalid_config}
  def from_config(blockchains) do
    from_config(blockchains, Application.get_env(:slurp, :new_head_subscriptions, %{}))
  end

  @spec from_config([blockchain], map) ::
          {:ok, [new_head_subscription]} | {:error, invalid_config}
  def from_config(blockchains, config) when is_map(config) do
    keyed_blockchains =
      blockchains
      |> Enum.reduce(
        %{},
        fn blockchain, acc -> Map.put(acc, blockchain.id, blockchain) end
      )

    new_head_subscriptions =
      config
      |> Enum.flat_map(fn {blockchains_query, handlers} ->
        keyed_blockchains
        |> Juice.squeeze(blockchains_query)
        |> Enum.flat_map(fn {blockchain_id, _blockchain} ->
          handlers
          |> Enum.map(fn handler ->
            attrs = Map.put(handler, :blockchain_id, blockchain_id)
            struct!(Specs.NewHeadSubscription, attrs)
          end)
        end)
      end)

    {:ok, new_head_subscriptions}
  end

  def from_config(_blockchains, config) do
    {:error,
     "invalid env :new_head_subscriptions for application :slurp. #{inspect(config)} is not a map"}
  end

  @spec find_by(list) :: new_head_subscription | nil
  def find_by(filters) do
    with {store_id, filters} <-
           Keyword.pop(filters, :store_id, Stores.NewHeadSubscriptionStore.default_store_id()) do
      store_id
      |> Stores.NewHeadSubscriptionStore.all()
      |> Enumerati.filter(filters)
      |> case do
        [] -> nil
        [subscription | _] -> subscription
      end
    end
  end

  @spec all(list) :: [new_head_subscription]
  def all(opts) do
    with {store_id, opts} <-
           Keyword.pop(opts, :store_id, Stores.NewHeadSubscriptionStore.default_store_id()),
         filters <- Keyword.get(opts, :where, []) do
      store_id
      |> Stores.NewHeadSubscriptionStore.all()
      |> Enumerati.filter(filters)
    end
  end

  @spec put(new_head_subscription) :: {:ok, {term, new_head_subscription}}
  @spec put(new_head_subscription, new_head_subscription_store_id) ::
          {:ok, {term, new_head_subscription}}
  def put(new_head_subscription, store_id \\ Stores.NewHeadSubscriptionStore.default_store_id()) do
    Stores.NewHeadSubscriptionStore.put(new_head_subscription, store_id)
  end
end
