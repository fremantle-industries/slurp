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
    {:ok, _log_subscriptions} = Slurp.Logs.load_subscriptions(blockchains)

    :ok
  end

  def start_phase(:blockchains_and_subscriptions, _start_type, _phase_args) do
    with ids <-
           Slurp.Blockchains.all()
           |> Enumerati.filter(start_on_boot: true)
           |> Enum.map(& &1.id) do
      case ids do
        [] -> :noop
        _ -> Slurp.Commander.start_blockchains([{:where, [id: ids]}])
      end
    end

    :ok
  end
end
