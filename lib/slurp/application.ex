defmodule Slurp.Application do
  use Application

  def start(_type, _args) do
    children = [
      Slurp.NewHeads.NewHeadSubscriptionStore,
      Slurp.Logs.LogSubscriptionStore,
      Slurp.Blockchains.BlockchainStore,
      Slurp.ConnectionsSupervisor,
      Slurp.Commander
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Slurp.Supervisor)
  end

  def start_phase(:hydrate, _start_type, _phase_args) do
    {:ok, blockchains} = Slurp.Blockchains.from_config()
    Enum.each(blockchains, &Slurp.Blockchains.put/1)
    {:ok, new_head_subscriptions} = Slurp.NewHeads.Subscriptions.from_config(blockchains)
    Enum.each(new_head_subscriptions, &Slurp.NewHeads.Subscriptions.put/1)
    {:ok, log_subscriptions} = Slurp.Logs.Subscriptions.from_config(blockchains)
    Enum.each(log_subscriptions, &Slurp.Logs.Subscriptions.put/1)
  end
end
