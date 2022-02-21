defmodule Slurp.IEx.Commands.LogSubscriptions do
  import Slurp.IEx.Commands.Table, only: [render!: 2]

  @header [
    "Blockchain ID",
    "Event Signature",
    "Hashed Event Signature",
    "Enabled",
    "Events",
    "Handler"
  ]

  @type store_id_opt :: {:store_id, atom}
  @type where_opt :: {:where, list}
  @type order_opt :: {:order, list}
  @type options :: [store_id_opt | where_opt | order_opt]

  @spec list(options) :: no_return
  def list(options) do
    options
    |> Slurp.Commander.log_subscriptions()
    |> format_rows()
    |> render!(@header)
  end

  defp format_rows(log_subscriptions) do
    log_subscriptions
    |> Enum.map(fn s ->
      [
        s.blockchain_id,
        s.event_signature,
        "#{s.hashed_event_signature |> String.slice(0..18)}...",
        s.enabled,
        s.event_mappings |> event_mapping_structs(),
        s.handler
      ]
      |> Enum.map(&format_col/1)
    end)
  end

  defp event_mapping_structs(event_mappings) do
    event_mappings
    |> Enum.map(fn {event, _abi} ->
      event
    end)
  end

  defp format_col(nil), do: "-"
  defp format_col({_, _, _} = mfa), do: mfa |> inspect
  defp format_col(val), do: val
end
