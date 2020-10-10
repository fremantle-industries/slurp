defmodule Slurp.Blockchains.Connection do
  use GenServer

  def start_link(id: id) do
    name = process_name(id)
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def process_name(name) do
    :"#{__MODULE__}_#{name}"
  end

  def init(state) do
    {:ok, state}
  end
end
