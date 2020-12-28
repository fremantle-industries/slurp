defmodule Slurp.IEx.Commands.Help do
  def help do
    IO.puts("""
    * help
    * blockchains [where: [...], order: [...]]
    * start_blockchains [where: [...]]
    * stop_blockchains [where: [...]]
    * new_head_subscriptions [where: [...], order: [...]]
    * log_subscriptions [where: [...], order: [...]]
    """)

    IEx.dont_display_result()
  end
end
