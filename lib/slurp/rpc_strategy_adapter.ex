defmodule Slurp.RpcStrategyAdapter do
  alias Slurp.Blockchains

  @type agent :: pid
  @type blockchain :: Blockchains.Blockchain.t()
  @type err_msg :: String.t() | atom
  @type strategy_options :: Blockchains.Blockchain.rpc_strategy_args()
  @type url :: String.t()

  @callback init(agent, blockchain, strategy_options) :: :ok | {:error, err_msg}
  @callback endpoint(agent) :: {:ok, url}
  @callback report_error(agent, err_msg) :: :ok
end
