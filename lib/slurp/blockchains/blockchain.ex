defmodule Slurp.Blockchains.Blockchain do
  alias __MODULE__

  @type id :: String.t()
  @type t :: %Blockchain{
          id: id,
          name: String.t(),
          network_id: pos_integer,
          chain_id: pos_integer,
          chain: String.t(),
          testnet: bool,
          start_on_boot: boolean(),
          rpc: [String.t()]
        }

  defstruct ~w[id name network_id chain_id chain testnet start_on_boot rpc]a

  defimpl Stored.Item do
    def key(blockchain), do: blockchain.id
  end
end
