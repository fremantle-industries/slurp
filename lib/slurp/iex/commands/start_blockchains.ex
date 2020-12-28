defmodule Slurp.IEx.Commands.StartBlockchains do
  @type store_id_opt :: {:store_id, atom}
  @type where_opt :: {:where, list}
  @type options :: [store_id_opt | where_opt]

  @spec start(options) :: no_return
  def start(options) do
    {started, already_started} = Slurp.Commander.start_blockchains(options)
    IO.puts("Started blockchains: #{started} new, #{already_started} already running")
    IEx.dont_display_result()
  end
end
