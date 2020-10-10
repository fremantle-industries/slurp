defmodule Slurp.IEx.Commands.StopBlockchains do
  @type store_id_opt :: {:store_id, atom}
  @type where_opt :: {:where, list}
  @type options :: [store_id_opt | where_opt]

  @spec stop(options) :: no_return
  def stop(options) do
    {stopped, stopped_already} = Slurp.Commander.stop_blockchains(options)
    IO.puts("Stopped blockchains: #{stopped} new, #{stopped_already} already stopped")
    IEx.dont_display_result()
  end
end
