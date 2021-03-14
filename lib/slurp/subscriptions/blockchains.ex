defmodule Slurp.Subscriptions.Blockchains do
  alias Slurp.{Stores, Specs}
  alias __MODULE__

  @type blockchain :: Specs.Blockchain.t()

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
          [struct!(Specs.Blockchain, Map.put(c, :id, id)) | acc]
        end
      )
      |> Enum.reverse()

    {:ok, blockchains}
  end

  def from_config(config) do
    {:error, "invalid env :blockchains for application :slurp. #{inspect(config)} is not a map"}
  end

  @spec all :: [blockchain]
  def all(store_id \\ Stores.BlockchainStore.default_store_id()) do
    Stores.BlockchainStore.all(store_id)
  end

  @spec put(blockchain) :: {:ok, {Specs.Blockchain.id(), blockchain}}
  def put(blockchain, store_id \\ Stores.BlockchainStore.default_store_id()) do
    Stores.BlockchainStore.put(blockchain, store_id)
  end
end
