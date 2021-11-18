defmodule Slurp.Blockchains do
  alias __MODULE__

  @type blockchain :: Blockchains.Blockchain.t()
  @type blockchain_id :: Blockchains.Blockchain.id()

  @spec from_config :: {:ok, list}
  def from_config do
    from_config(Application.get_env(:slurp, :blockchains, %{}))
  end

  @spec from_config(map) :: {:ok, list} | {:error, String.t()}
  def from_config(config) when is_map(config) do
    blockchains =
      config
      |> Enum.reduce(
        [],
        fn {id, c}, acc ->
          [struct!(Blockchains.Blockchain, Map.put(c, :id, id)) | acc]
        end
      )
      |> Enum.reverse()

    {:ok, blockchains}
  end

  def from_config(config) do
    {:error, "invalid env :blockchains for application :slurp. #{inspect(config)} is not a map"}
  end

  @spec find(blockchain_id) :: {:ok, blockchain} | {:error, :not_found}
  def find(blockchain_id, store_id \\ Blockchains.BlockchainStore.default_store_id()) do
    Blockchains.BlockchainStore.find(blockchain_id, store_id)
  end

  @spec all :: [blockchain]
  def all(store_id \\ Blockchains.BlockchainStore.default_store_id()) do
    Blockchains.BlockchainStore.all(store_id)
  end

  @spec put(blockchain) :: {:ok, {Blockchains.Blockchain.id(), blockchain}}
  def put(blockchain, store_id \\ Blockchains.BlockchainStore.default_store_id()) do
    Blockchains.BlockchainStore.put(blockchain, store_id)
  end

  @spec endpoint(blockchain) :: {:ok, term} | {:error, :no_endpoint}
  def endpoint(blockchain) do
    Blockchains.Endpoint.get(blockchain)
  end
end
