defmodule Slurp.RpcStrategyAdapter.RoundRobin do
  @behaviour Slurp.RpcStrategyAdapter
  alias Slurp.{Blockchains, RpcStrategyAdapter}

  defmodule Buffer do
    @type t :: %Buffer{
            entries: list,
            size: non_neg_integer,
            max_size: non_neg_integer
          }
    defstruct ~w[entries size max_size]a

    @spec add(t(), term) :: t()
    def add(%{size: size, max_size: size, entries: [_oldest | tail]} = buffer, entry) do
      %Buffer{buffer | entries: tail ++ [entry]}
    end

    def add(%{size: size, entries: entries} = buffer, entry) do
      %Buffer{buffer | size: size + 1, entries: entries ++ [entry]}
    end

    @spec clear_buffer(t(), list) :: t()
    def clear_buffer(buffer, new_list) when is_list(new_list) do
      %Buffer{buffer | size: length(new_list), entries: new_list}
    end
  end

  defmodule State do
    @behaviour Access
    @type blockchain :: Blockchains.Blockchain.t()
    @type buffer :: Buffer.t()
    @type endpoints :: [RpcStrategyAdapter.url()]
    @type delta_unit :: atom
    @type t :: %State{
            blockchain: blockchain,
            endpoints: endpoints,
            threshold: non_neg_integer,
            period: non_neg_integer,
            unit: delta_unit,
            buffer: buffer
          }
    defstruct ~w[blockchain endpoints threshold period unit buffer]a

    defdelegate get(v, key, default), to: Map
    defdelegate fetch(v, key), to: Map
    defdelegate get_and_update(v, key, func), to: Map
    defdelegate pop(v, key), to: Map
  end

  @type agent :: RpcStrategyAdapter.agent()
  @type blockchain :: Blockchains.Blockchain.t()
  @type strategy_options :: RpcStrategyAdapter.strategy_options()
  @type err_msg :: RpcStrategyAdapter.err_msg()
  @type agent_state :: State.t()
  @type url :: RpcStrategyAdapter.url()
  @type urls :: [url]

  @spec init(agent, blockchain, strategy_options) :: :ok | {:error, err_msg}
  def init(agent, blockchain, strategy_options) do
    case blockchain.rpc do
      nil ->
        {:error, :no_endpoints}

      endpoints ->
        Agent.update(agent, fn _ ->
          %State{
            blockchain: blockchain,
            endpoints: endpoints,
            threshold: Keyword.get(strategy_options, :threshold, 3),
            period: Keyword.get(strategy_options, :period, 1),
            unit: Keyword.get(strategy_options, :unit, :minute),
            buffer: %Buffer{
              size: 0,
              max_size: Keyword.get(strategy_options, :threshold, 3),
              entries: []
            }
          }
        end)
    end
  end

  @spec endpoint(agent) :: {:ok, url}
  def endpoint(agent) do
    {:ok, Agent.get(agent, fn state -> List.first(state.endpoints) end)}
  end

  @spec report_error(agent, err_msg) :: :ok
  def report_error(agent, _err_msg) do
    Agent.get(agent, & &1)
    |> add_now()
    |> maybe_switch_endpoint()
    |> (&Agent.update(agent, fn _ -> &1 end)).()

    :ok
  end

  defp unit_to_seconds(atom), do: Map.get(%{second: 1, minute: 60, hour: 360}, atom, nil)

  defp add_now(%State{buffer: buffer} = state) do
    Kernel.put_in(state, [:buffer], Buffer.add(buffer, now()))
  end

  defp now() do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp maybe_switch_endpoint(
         %State{
           buffer: %Buffer{entries: entries, size: size, max_size: size},
           period: period,
           unit: unit
         } = state
       ) do
    if List.last(entries) - List.first(entries) < period * unit_to_seconds(unit) do
      state
      |> rot_endpoints()
      |> clear_buffer()
    else
      state
    end
  end

  defp maybe_switch_endpoint(state), do: state

  defp rot_endpoints([h | t] = list) when is_list(list), do: t ++ [h]

  defp rot_endpoints(state) do
    Kernel.put_in(state, [:endpoints], rot_endpoints(state.endpoints))
  end

  defp clear_buffer(%State{buffer: buffer} = state) do
    Kernel.put_in(state, [:buffer], Buffer.clear_buffer(buffer, []))
  end
end
