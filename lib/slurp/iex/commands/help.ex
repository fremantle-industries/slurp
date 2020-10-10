defmodule Slurp.IEx.Commands.Help do
  def help do
    IO.puts("""
    * help
    * blockchains [where: [...], order: [...]]
    * start_blockchains [where: [...]
    * stop_blockchains [where: [...]
    """)

    IEx.dont_display_result()
  end
end
