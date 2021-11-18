defmodule Slurp.Blockchains.Endpoint do
  @spec get(t) :: {:ok, term} | {:error, :no_endpoints}
  def get(%Blockchain{rpc_strategy: nil} = blockchain) do
    case List.first(blockchain.rpc) do
      nil -> {:error, :no_endpoints}
      endpoint -> {:ok, endpoint}
    end
  end

  def get(blockchain) do
    Slurp.RpcAgent.endpoint(blockchain)
  end
end
