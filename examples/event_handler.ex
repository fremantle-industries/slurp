defmodule Examples.EventHandler do
  require Logger

  def handle_erc20_approval(blockchain, log, event) do
    handle_event(blockchain, log, event)
  end

  def handle_erc20_specific_address_approval(blockchain, %{"address" => address} = log, event) do
    Logger.info "received event: #{inspect event} for specific contract address: #{inspect address}"
    handle_event(blockchain, log, event)
  end

  def handle_erc20_transfer(blockchain, log, event) do
    handle_event(blockchain, log, event)
  end

  def handle_uniswap_v2_mint(blockchain, log, event) do
    handle_event(blockchain, log, event)
  end

  def handle_uniswap_v2_burn(blockchain, log, event) do
    handle_event(blockchain, log, event)
  end

  def handle_uniswap_v2_swap(blockchain, log, event) do
    handle_event(blockchain, log, event)
  end

  def handle_uniswap_v2_sync(blockchain, log, event) do
    handle_event(blockchain,log,  event)
  end

  defp handle_event(_blockchain, %{"blockNumber" => hex_block_number}= _log, event) do
    {:ok, block_number} = Slurp.Utils.hex_to_integer(hex_block_number)
    Logger.info "received event: #{inspect event}, block_number: #{block_number}"
  end
end
