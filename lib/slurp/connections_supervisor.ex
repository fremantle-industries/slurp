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

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, _pid} = ok ->
        :telemetry.execute([:slurp, :blockchains, :start], %{}, %{id: id})
        ok

      {:ok, _pid, _info} = ok ->
        :telemetry.execute([:slurp, :blockchains, :start], %{}, %{id: id})
        ok

      result ->
        result
    end
  end

  @spec terminate_connection(blockchain_id) :: :ok | {:error, :not_found}
  def terminate_connection(id) do
    case find_connection(id) do
      nil ->
        {:error, :not_found}

      pid ->
        case DynamicSupervisor.terminate_child(__MODULE__, pid) do
          :ok = ok ->
            :telemetry.execute([:slurp, :blockchains, :stop], %{}, %{id: id})
            ok

          {:error, _reason} = error ->
            error
        end
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
