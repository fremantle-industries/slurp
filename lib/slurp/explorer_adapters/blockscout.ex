defmodule Slurp.ExplorerAdapters.Blockscout do
  @behaviour Slurp.ExplorerAdapter

  @impl true
  def home_url(endpoint) do
    endpoint
  end

  @impl true
  def address_url(endpoint, address) do
    "#{endpoint}/address/#{address}/transactions"
  end
end
