defmodule Slurp.Specs.NewHeadSubscription do
  alias Slurp.Specs
  alias __MODULE__

  @type t :: %NewHeadSubscription{
          enabled: boolean,
          blockchain_id: Specs.Blockchain.id(),
          handler: {module, atom, list}
        }

  defstruct ~w[enabled blockchain_id handler]a

  defimpl Stored.Item do
    def key(subscription), do: subscription.blockchain_id
  end
end
