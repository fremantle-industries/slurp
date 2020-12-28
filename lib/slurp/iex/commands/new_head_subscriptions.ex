defmodule Slurp.IEx.Commands.NewHeadSubscriptions do
  import Slurp.IEx.Commands.Table, only: [render!: 2]

  @header [
    "Blockchain ID",
    "Enabled",
    "Handler"
  ]

  @type store_id_opt :: {:store_id, atom}
  @type where_opt :: {:where, list}
  @type order_opt :: {:order, list}
  @type options :: [store_id_opt | where_opt | order_opt]

  @spec list(options) :: no_return
  def list(options) do
    options
    |> Slurp.Commander.new_head_subscriptions()
    |> format_rows()
    |> render!(@header)
  end

  defp format_rows(new_head_subscriptions) do
    new_head_subscriptions
    |> Enum.map(fn s ->
      [
        s.blockchain_id,
        s.enabled,
        s.handler
      ]
      |> Enum.map(&format_col/1)
    end)
  end

  defp format_col(nil), do: "-"
  defp format_col({_, _, _} = mfa), do: mfa |> inspect
  defp format_col(val), do: val
end
