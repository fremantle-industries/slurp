defmodule Slurp.Specs.LogSubscription do
  alias Slurp.{Adapter, Specs}
  alias __MODULE__

  @type t :: %LogSubscription{
          enabled: boolean,
          blockchain_id: Specs.Blockchain.id(),
          event_signature: Adapter.event_signature(),
          hashed_event_signature: Adapter.hashed_event_signature(),
          struct: module,
          handler: {module, atom, list},
          abi: [map]
        }

  defstruct ~w[
    enabled
    blockchain_id
    event_signature
    hashed_event_signature
    struct
    handler
    abi
  ]a

  defimpl Stored.Item do
    def key(log_subscription) do
      {log_subscription.blockchain_id, log_subscription.event_signature}
    end
  end
end
