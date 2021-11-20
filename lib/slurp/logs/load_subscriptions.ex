defmodule Slurp.Logs.LoadSubscriptions do
  alias Slurp.{Blockchains, Logs}

  @type blockchain :: Blockchains.Blockchain.t()
  @type blockchain_id :: Blockchains.Blockchain.id()
  @type config :: map
  @type log_subscription :: Logs.LogSubscription.t()
  @type log_subscription_store_id :: Logs.LogSubscriptionStore.store_id()
  @type invalid_config :: String.t()

  @spec load([blockchain], config) :: {:ok, [log_subscription]} | {:error, invalid_config}
  def load(blockchains, config) when is_map(config) do
    parse(blockchains, config)
  end

  def load(_, config) do
    {:error, invalid_config_reason(config)}
  end

  defp parse(blockchains, config) do
    indexed_blockchains = index_blockchains(blockchains)
    log_subscriptions = build_log_subscriptions(config, indexed_blockchains)
    Enum.each(log_subscriptions, &Logs.LogSubscriptionStore.put/1)

    {:ok, log_subscriptions}
  end

  defp index_blockchains(blockchains) do
    blockchains
    |> Enum.reduce(
      %{},
      fn blockchain, acc ->
        Map.put(acc, blockchain.id, blockchain)
      end
    )
  end

  defp build_log_subscriptions(config, indexed_blockchains) do
    config
    |> Enum.flat_map(fn {query, events_or_pipeline} ->
      indexed_blockchains
      |> filter_blockchains(query)
      |> Enum.flat_map(fn blockchain ->
        events_or_pipeline
        |> case do
          e when is_map(e) -> e
          p when is_list(p) -> pipeline_to_events(p)
          _ -> %{}
        end
        |> parse_events(blockchain)
      end)
    end)
  end

  defp filter_blockchains(indexed_blockchains, query) do
    indexed_blockchains
    |> Juice.squeeze(query)
    |> Map.values()
  end

  defp pipeline_to_events(pipeline) do
    pipeline
    |> Enum.flat_map(
      fn {m, f, a} ->
        apply(m, f, a)
      end
    )
    |> Map.new()
  end

  defp parse_events(events, blockchain) do
    events
    |> Enum.flat_map(fn {event_signature, handlers} ->
      handlers
      |> Enum.map(fn handler ->
        hashed_event_sig = Slurp.Adapter.hash_event_signature(blockchain, event_signature)

        attrs =
          Map.merge(handler, %{
            blockchain_id: blockchain.id,
            event_signature: event_signature,
            hashed_event_signature: hashed_event_sig
          })

        struct!(Logs.LogSubscription, attrs)
      end)
    end)
  end

  defp invalid_config_reason(config) do
    "invalid env :log_subscriptions for application :slurp. ~s is not a map"
    |> :io_lib.format([
      inspect(config)
    ])
  end
end
