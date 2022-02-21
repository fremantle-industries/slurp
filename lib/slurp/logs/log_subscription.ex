defmodule Slurp.Logs.LogSubscription do
  alias __MODULE__

  @type event_mapping :: {module, map}
  @type config :: %{
    enabled: boolean,
    handler: mfa,
    event_mappings: [event_mapping]
  }
  @type t :: %LogSubscription{
          enabled: boolean,
          blockchain_id: Slurp.Blockchains.Blockchain.id(),
          event_signature: Slurp.Adapter.event_signature(),
          hashed_event_signature: Slurp.Adapter.hashed_event_signature(),
          handler: {module, atom, list},
          event_mappings: [event_mapping]
        }

  defstruct ~w[
    enabled
    blockchain_id
    event_signature
    hashed_event_signature
    handler
    event_mappings
  ]a

  defimpl Stored.Item do
    def key(log_subscription) do
      {log_subscription.blockchain_id, log_subscription.event_signature}
    end
  end
end
