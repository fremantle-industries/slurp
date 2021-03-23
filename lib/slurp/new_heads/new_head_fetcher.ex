defmodule Slurp.NewHeads.NewHeadFetcher do
  use GenServer
  require Logger
  alias Slurp.{Blockchains, Logs}

  defmodule State do
    @type blockchain :: Blockchains.Blockchain.t()
    @type subscription :: mfa | nil
    @type t :: %State{
            blockchain: blockchain,
            endpoint: String.t(),
            subscription: subscription,
            last_block_number: non_neg_integer() | nil
          }

    defstruct ~w[blockchain endpoint subscription last_block_number]a
  end

  @type blockchain_id :: Blockchains.Blockchain.id()

  @spec start_link(
          blockchain: State.blockchain(),
          endpoint: Slurp.Adapter.endpoint(),
          subscription: State.subscription()
        ) :: GenServer.on_start()
  def start_link(blockchain: blockchain, endpoint: endpoint, subscription: subscription) do
    name = process_name(blockchain.id)
    state = %State{blockchain: blockchain, endpoint: endpoint, subscription: subscription}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @spec process_name(blockchain_id) :: atom
  def process_name(id), do: :"#{__MODULE__}_#{id}"

  @spec check(blockchain_id) :: :ok
  def check(id) do
    id
    |> process_name
    |> GenServer.cast(:check)
  end

  @impl true
  def init(state) do
    Logger.metadata(blockchain_id: state.blockchain.id)
    {:ok, state}
  end

  @impl true
  def handle_cast(:check, state) do
    state.blockchain
    |> Slurp.Adapter.block_number(state.endpoint)
    |> case do
      {:ok, block_number} ->
        if state.last_block_number == nil || block_number > state.last_block_number do
          Logger.debug(
            "received new head: #{inspect(block_number)}, previous: #{
              state.last_block_number || "-"
            }"
          )

          state = %{state | last_block_number: block_number}
          {:noreply, state, {:continue, {:publish, block_number}}}
        else
          {:noreply, state}
        end

      {:error, reason} ->
        Logger.warn(
          "could not fetch latest block number for #{state.blockchain.id}: #{inspect(reason)}"
        )

        {:noreply, state}
    end
  end

  @impl true
  def handle_continue({:publish, block_number}, state) do
    Logs.LogFetcher.new_head(state.blockchain.id, block_number)
    call_subscription(block_number, state)
    {:noreply, state}
  end

  defp call_subscription(_, %State{subscription: nil}), do: nil

  defp call_subscription(block_number, state) do
    {mod, func, extra_args} = state.subscription.handler
    apply(mod, func, [state.blockchain, block_number] ++ extra_args)
  end
end
