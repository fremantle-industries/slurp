defmodule Slurp.IEx do
  alias Slurp.IEx.Commands

  @spec help() :: no_return
  defdelegate help, to: Commands.Help

  @spec blockchains() :: no_return
  @spec blockchains(Commands.Blockchains.options()) :: no_return
  defdelegate blockchains(options \\ []), to: Commands.Blockchains, as: :list

  @spec start_blockchains() :: no_return
  @spec start_blockchains(Commands.Blockchains.options()) :: no_return
  defdelegate start_blockchains(options \\ []), to: Commands.StartBlockchains, as: :start

  @spec stop_blockchains() :: no_return
  @spec stop_blockchains(Commands.Blockchains.options()) :: no_return
  defdelegate stop_blockchains(options \\ []), to: Commands.StopBlockchains, as: :stop

  @spec new_head_subscriptions() :: no_return
  @spec new_head_subscriptions(Commands.NewHeadSubscriptions.options()) :: no_return
  defdelegate new_head_subscriptions(options \\ []), to: Commands.NewHeadSubscriptions, as: :list

  @spec log_subscriptions() :: no_return
  @spec log_subscriptions(Commands.LogSubscriptions.options()) :: no_return
  defdelegate log_subscriptions(options \\ []), to: Commands.LogSubscriptions, as: :list
end
