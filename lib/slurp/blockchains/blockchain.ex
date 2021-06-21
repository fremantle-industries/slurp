defmodule Slurp.Blockchains.Blockchain do
  alias __MODULE__

  @type id :: String.t()
  @type endpoint :: String.t()
  @type explorer_adapter :: module
  @type explorer_endpoint :: String.t()
  @type t :: %Blockchain{
          id: id,
          name: String.t(),
          adapter: module,
          network_id: pos_integer,
          chain_id: pos_integer,
          chain: String.t(),
          testnet: boolean,
          start_on_boot: boolean,
          timeout: pos_integer,
          new_head_initial_history: pos_integer,
          poll_interval_ms: non_neg_integer,
          explorer: {explorer_adapter, explorer_endpoint} | nil,
          rpc: [endpoint]
        }

  defstruct ~w[
    id
    name
    adapter
    network_id
    chain_id
    chain
    testnet
    start_on_boot
    timeout
    new_head_initial_history
    poll_interval_ms
    explorer
    rpc
  ]a

  @spec endpoint(t) :: {:ok, endpoint} | {:error, :no_endpoints}
  def endpoint(blockchain) do
    case List.first(blockchain.rpc) do
      nil -> {:error, :no_endpoints}
      endpoint -> {:ok, endpoint}
    end
  end

  defimpl Stored.Item do
    def key(blockchain), do: blockchain.id
  end
end
