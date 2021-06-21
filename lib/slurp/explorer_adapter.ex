defmodule Slurp.ExplorerAdapter do
  @type endpoint :: String.t()
  @type address :: Slurp.Adapter.address()
  @type url :: String.t()

  @callback home_url(endpoint) :: url
  @callback address_url(endpoint, address) :: url
end
