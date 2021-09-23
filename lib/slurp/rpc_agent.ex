defmodule Slurp.RpcAgent do
  use Agent
  require Logger
  alias Slurp.{Blockchains, RpcStrategyAdapter}

  @type agent_state :: RpcStrategyAdapter.agent_state()
  @type id :: Blockchains.Blockchain.id()
  @type blockchain :: Blockchains.Blockchain.t()
  @type err_msg :: RpcStrategyAdapter.err_msg()
  @type url :: RpcStrategyAdapter.url()
  @type agent :: RpcStrategyAdapter.agent()
  @type rpc_strategy :: module

  @spec start_link(blockchain: blockchain) ::
          Agent.on_start()
  def start_link(blockchain: blockchain) do
    name = process_name(blockchain.id)
    {:ok, agent} = Agent.start_link(fn -> {} end, name: name)
    init(agent, blockchain)
    {:ok, agent}
  end

  @spec process_name(id) :: atom
  def process_name(id), do: :"#{__MODULE__}_#{id}"

  @spec init(agent, blockchain) :: :ok
  def init(agent, blockchain) do
    with {rpc_strategy_adapter, strategy_options} <- blockchain.rpc_strategy do
      case rpc_strategy_adapter.init(agent, blockchain, strategy_options) do
        {:error, reason} ->
          Logger.error(
            "could not initial rpc agent state '#{process_name(agent.blockchain)}' '#{
              inspect(strategy_options)
            }': #{inspect(reason)}"
          )
        :ok -> :ok
      end
    end
  end

  @spec endpoint(blockchain) :: {:ok, url} | {:error, err_msg}
  def endpoint(blockchain) do
    with pid <- blockchain.id |> process_name() |> Process.whereis(),
         rpc_strategy <- blockchain.rpc_strategy do
      case {pid, rpc_strategy} do
        {nil, _} ->
          {:error, :process_not_found}

        {_, nil} ->
          {:error, :rpc_strategy_adapter_not_found}

        {pid, rpc_strategy} ->
          apply(elem(rpc_strategy, 0), :endpoint, [pid])
      end
    end
  end

  @spec report_error(blockchain, err_msg) :: :ok | {:error, err_msg}
  def report_error(blockchain, err_msg) do
    Logger.debug("retrieved error report from #{inspect(blockchain.id)} logs for reason: #{inspect(err_msg)}")
    with pid <- blockchain.id |> process_name() |> Process.whereis(),
    rpc_strategy <- blockchain.rpc_strategy do
      case {pid, rpc_strategy} do
        {nil, _} ->
          {:error, :process_not_found}

        {_, nil} ->
          {:error, :rpc_strategy_adapter_not_found}

        {pid, rpc_strategy} ->
          apply(elem(rpc_strategy, 0), :report_error, [pid, err_msg])
      end
    end
  end
end
