defmodule Examples.EventHandler do
  require Logger

  def handle_token_approval(blockchain, log, event) do
    handle_event(blockchain, log, event)
  end

  def handle_token_approval_for_all(blockchain, log, event) do
    handle_event(blockchain, log, event)
  end

  def handle_token_transfer(blockchain, log, event) do
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

    "received event=~s, block_number=~w"
    |> :io_lib.format([
      inspect(event),
      block_number
    ])
    |> Logger.info()
  end
end
