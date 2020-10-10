defmodule Slurp.IEx.Commands.Blockchains do
  import Slurp.IEx.Commands.Table, only: [render!: 2]

  @header [
    "ID",
    "Name",
    "Network ID",
    "Chain ID",
    "Chain",
    "Testnet",
    "RPC"
  ]

  @type store_id_opt :: {:store_id, atom}
  @type where_opt :: {:where, list}
  @type order_opt :: {:order, list}
  @type options :: [store_id_opt | where_opt | order_opt]

  @spec list(options) :: no_return
  def list(options) do
    options
    |> Slurp.Commander.blockchains()
    |> format_rows()
    |> render!(@header)
  end

  defp format_rows(blockchains) do
    blockchains
    |> Enum.map(fn b ->
      [
        b.id,
        b.name,
        b.network_id,
        b.chain_id,
        b.chain,
        b.testnet,
        b.rpc
      ]
      |> Enum.map(&format_col/1)
    end)
  end

  defp format_col([]), do: "-"
  defp format_col([head | []]), do: head
  defp format_col([head | tail]), do: "#{head}, (#{Enum.count(tail)} more)"
  # defp format_col(val) when is_pid(val) or is_map(val), do: val |> inspect()
  defp format_col(nil), do: "-"
  defp format_col(val), do: val
end
