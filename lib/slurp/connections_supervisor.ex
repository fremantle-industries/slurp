defmodule Slurp.ConnectionsSupervisor do
  use DynamicSupervisor

  @type blockchain_id :: Slurp.Blockchains.Blockchain.id()

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec start_connection(blockchain_id) :: DynamicSupervisor.on_start_child()
  def start_connection(id) do
    child_spec = {Slurp.ConnectionSupervisor, [id: id]}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @spec terminate_connection(blockchain_id) :: :ok | {:error, :not_found}
  def terminate_connection(id) do
    case find_connection(id) do
      nil -> {:error, :not_found}
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp find_connection(id) do
    id
    |> Slurp.ConnectionSupervisor.process_name()
    |> Process.whereis()
  end
end
