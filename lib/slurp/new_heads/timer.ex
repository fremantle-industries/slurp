defmodule Slurp.NewHeads.Timer do
  use GenServer
  alias Slurp.{NewHeads, Specs}

  defmodule State do
    @type blockchain :: Specs.Blockchain.t()
    @type t :: %State{
            blockchain: blockchain
          }

    defstruct ~w[blockchain]a
  end

  @type blockchain :: Specs.Blockchain.t()
  @type blockchain_id :: Specs.Blockchain.id()

  @spec start_link(blockchain: blockchain) :: GenServer.on_start()
  def start_link(blockchain: blockchain) do
    name = process_name(blockchain.id)
    state = %State{blockchain: blockchain}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @spec process_name(blockchain_id) :: atom
  def process_name(id), do: :"#{__MODULE__}_#{id}"

  def init(state) do
    Process.send(self(), :poll, [])
    {:ok, state}
  end

  def handle_info(:poll, state) do
    Process.send_after(self(), :poll, state.blockchain.poll_interval_ms)
    NewHeads.NewHeadFetcher.check(state.blockchain.id)
    {:noreply, state}
  end
end
