defmodule Slurp.Logs.LogFetcher do
  use GenServer
  require Logger
  alias Slurp.{Adapter, Blockchains, Logs}

  defmodule State do
    @type block_number :: Adapter.block_number()
    @type hashed_event_signature :: Adapter.hashed_event_signature()
    @type log_subscription :: Logs.LogSubscription.t()

    @type t :: %State{
            blockchain: Blockchains.Blockchain.t(),
            endpoint: Adapter.endpoint(),
            subscriptions: %{
              hashed_event_signature => log_subscription
            },
            topics: [hashed_event_signature],
            last_block_number: block_number | nil
          }

    defstruct ~w[blockchain endpoint subscriptions topics last_block_number]a
  end

  @type blockchain :: Blockchains.Blockchain.t()
  @type blockchain_id :: Blockchains.Blockchain.id()

  @spec start_link(blockchain: blockchain, subscriptions: [State.log_subscription()]) ::
          GenServer.on_start()
  def start_link(blockchain: blockchain, subscriptions: subscriptions) do
    name = process_name(blockchain.id)
    topics = Enum.map(subscriptions, & &1.hashed_event_signature)
    {:ok, endpoint} = Blockchains.Blockchain.endpoint(blockchain)

    state = %State{
      blockchain: blockchain,
      endpoint: endpoint,
      subscriptions: index_subscriptions(subscriptions),
      topics: topics
    }

    GenServer.start_link(__MODULE__, state, name: name)
  end

  @spec new_head(blockchain_id, State.block_number()) :: :ok
  def new_head(id, block_number) do
    id
    |> process_name
    |> GenServer.cast({:new_head, block_number})
  end

  @spec process_name(blockchain_id) :: atom
  def process_name(id), do: :"#{__MODULE__}_#{id}"

  def init(state) do
    Logger.metadata(blockchain_id: state.blockchain.id)
    {:ok, state}
  end

  def handle_cast({:new_head, block_number}, state) do
    # TODO: Handle timeout
    # TODO: Handle unable to retrieve history lookback
    with {:ok, logs} <- get_logs(block_number, state) do
      Logger.debug("retrieved #{Enum.count(logs)} logs for subscriptions")

      logs
      |> Enum.each(fn log ->
        {:ok, log_hashed_event_signature} =
          Slurp.Adapter.log_hashed_event_signature(state.blockchain, log)

        state.subscriptions
        |> Map.get(log_hashed_event_signature)
        |> case do
          nil ->
            Logger.warn(
              "could not find subscription, log_hashed_event_signature: #{
                log_hashed_event_signature
              }, topics: #{inspect(state.topics)}"
            )

          subscription ->
            with {:ok, event} <-
                   Slurp.Adapter.deserialize_log_event(state.blockchain, log, subscription) do
              {mod, func, extra_args} = subscription.handler
              args = [state.blockchain, log, event] ++ extra_args
              apply(mod, func, args)
            else
              {:error, reason} ->
                Logger.warn("could not deserialize log event: #{inspect(reason)}")
            end
        end
      end)
    else
      els ->
        Logger.warn("could not retrieve logs: #{inspect(els)}")
    end

    {:noreply, %{state | last_block_number: block_number}}
  end

  defp index_subscriptions(subscriptions) do
    subscriptions
    |> Enum.reduce(
      %{},
      fn subscription, acc ->
        Map.put(acc, subscription.hashed_event_signature, subscription)
      end
    )
  end

  defp block_range(current_block_number, last_block_number, history) do
    from_block = last_block_number || max(current_block_number - history, 0)
    {from_block, current_block_number}
  end

  defp get_logs(_, %State{topics: []}), do: {:ok, []}

  defp get_logs(block_number, state) do
    {from_block, to_block} =
      block_range(
        block_number,
        state.last_block_number,
        state.blockchain.new_head_initial_history
      )

    Logger.debug("get logs for new head from: #{from_block}, to: #{to_block}")

    {:ok, from_hex_block} = from_block |> Slurp.Utils.integer_to_hex()
    {:ok, to_hex_block} = to_block |> Slurp.Utils.integer_to_hex()

    # TODO: Support decamelized keys
    filter = %{
      topics: [state.topics],
      fromBlock: from_hex_block,
      toBlock: to_hex_block
    }

    Slurp.Adapter.get_logs(state.blockchain, filter, state.endpoint)
  end
end
