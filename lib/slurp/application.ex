defmodule Slurp.Application do
  use Application

  def start(_type, _args) do
    children = [
      Acme.Scheduler,
      Slurp.Blockchains.BlockchainStore,
      Slurp.Blockchains.ConnectionSupervisor,
      # Slurp.NewHeadsProducer,
      # Slurp.NewHeadsSupervisor,
      # Slurp.LogEventsSupervisor,
      # Slurp.TransactionsSupervisor
      Slurp.Commander
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Slurp.Supervisor)
  end

  def start_phase(:hydrate, _start_type, _phase_args) do
    {:ok, blockchains} = Slurp.Blockchains.from_config()
    Enum.each(blockchains, &Slurp.Blockchains.put/1)
  end
end
