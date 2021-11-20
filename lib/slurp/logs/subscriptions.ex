defmodule Slurp.Logs.Subscriptions do
  alias Slurp.Logs

  @type log_subscription :: Logs.LogSubscription.t()
  @type log_subscription_store_id :: Logs.LogSubscriptionStore.store_id()

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
end
