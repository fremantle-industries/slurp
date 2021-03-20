defmodule Slurp.Logs.LogSubscription do
  alias __MODULE__

  @type t :: %LogSubscription{
          enabled: boolean,
          blockchain_id: Slurp.Blockchains.Blockchain.id(),
          event_signature: Slurp.Adapter.event_signature(),
          hashed_event_signature: Slurp.Adapter.hashed_event_signature(),
          struct: module,
          handler: {module, atom, list},
          abi: [map],
          address: String.t()
        }

  defstruct ~w[
    enabled
    blockchain_id
    event_signature
    hashed_event_signature
    struct
    handler
    abi
    address
  ]a

  defimpl Stored.Item do
    def key(log_subscription) do
      {log_subscription.blockchain_id, log_subscription.event_signature, log_subscription.address}
    end
  end
end
