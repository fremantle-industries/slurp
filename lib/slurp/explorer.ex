defmodule Slurp.Explorer do
  @type blockchain :: Slurp.Blockchains.Blockchain.t()
  @type address :: Slurp.Adapter.address()

  @spec address_url(blockchain, address) :: String.t() | nil
  def address_url(blockchain, address) do
    case blockchain.explorer do
      {explorer_adapter, endpoint} -> explorer_adapter.address_url(endpoint, address)
      nil -> nil
    end
  end
end
