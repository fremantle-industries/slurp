defmodule TestSupport.Blockchains do
  alias Slurp.{Specs, Stores}
  def put_blockchain(attributes, store_id) do
    {:ok, _} =
      Specs.Blockchain
      |> struct(attributes)
      |> Stores.BlockchainStore.put(store_id)
  end

  def put_blockchain!(attributes, store_id) do
    {:ok, _} =
      Specs.Blockchain
      |> struct!(attributes)
      |> Stores.BlockchainStore.put(store_id)
  end
end
