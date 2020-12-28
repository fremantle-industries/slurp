defmodule TestSupport.Blockchains do
  def put_blockchain(attributes, store_id) do
    {:ok, _} =
      Slurp.Blockchains.Blockchain
      |> struct(attributes)
      |> Slurp.Blockchains.BlockchainStore.put(store_id)
  end

  def put_blockchain!(attributes, store_id) do
    {:ok, _} =
      Slurp.Blockchains.Blockchain
      |> struct!(attributes)
      |> Slurp.Blockchains.BlockchainStore.put(store_id)
  end
end
