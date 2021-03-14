defmodule Slurp.Application do
  use Application

  def start(_type, _args) do
    children = [
      Slurp.Stores.NewHeadSubscriptionStore,
      Slurp.Stores.LogSubscriptionStore,
      Slurp.Stores.BlockchainStore,
      Slurp.ConnectionsSupervisor,
      Slurp.Commander
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Slurp.Supervisor)
  end

  def start_phase(:hydrate, _start_type, _phase_args) do
    {:ok, blockchains} = Slurp.Subscriptions.Blockchains.from_config()
    Enum.each(blockchains, &Slurp.Subscriptions.Blockchains.put/1)
    {:ok, new_head_subscriptions} = Slurp.Subscriptions.NewHeads.from_config(blockchains)
    Enum.each(new_head_subscriptions, &Slurp.Subscriptions.NewHeads.put/1)
    {:ok, log_subscriptions} = Slurp.Subscriptions.Logs.from_config(blockchains)
    Enum.each(log_subscriptions, &Slurp.Subscriptions.Logs.put/1)
    :ok
  end

  def start_phase(:blockchains_and_subscriptions, _start_type, _phase_args) do
    with ids <- Slurp.Subscriptions.Blockchains.all()
      |> Enumerati.filter([start_on_boot: true])
      |> Enum.map(& &1.id)
    do
      case ids do
        [] -> :noop
        _ -> Slurp.Commander.start_blockchains([{:where, [id: ids]}])
      end
    end
    :ok
  end
end
