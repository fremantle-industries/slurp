defmodule Slurp.ExplorerAdapters.Etherscan do
  @behaviour Slurp.ExplorerAdapter

  @impl true
  def home_url(endpoint) do
    endpoint
  end

  @impl true
  def address_url(endpoint, address) do
    "#{endpoint}/address/#{address}"
  end
end
