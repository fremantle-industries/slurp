defmodule Examples.NewHeadHandler do
  require Logger

  def handle_new_head(_blockchain, block_number) do
    Logger.info "received new head: #{block_number}"
  end
end
