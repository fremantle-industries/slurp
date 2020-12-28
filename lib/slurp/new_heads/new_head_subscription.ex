defmodule Slurp.NewHeads.NewHeadSubscription do
  alias __MODULE__

  @type t :: %NewHeadSubscription{
          enabled: boolean,
          blockchain_id: Slurp.Blockchains.Blockchain.id(),
          handler: {module, atom, list}
        }

  defstruct ~w[enabled blockchain_id handler]a

  defimpl Stored.Item do
    def key(subscription), do: subscription.blockchain_id
  end
end
