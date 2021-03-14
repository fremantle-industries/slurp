defmodule Slurp.ConnectionSupervisor do
  use Supervisor
  alias Slurp.{Subscriptions, Stores, Specs, NewHeads, Logs}

  @type blockchain_id :: Specs.Blockchain.id()

  @spec start_link(id: blockchain_id) ::
          Supervisor.on_start() | {:error, :blockchain_not_found | :rpc_endpoint_not_found}
  def start_link(id: blockchain_id) do
    with {:ok, blockchain} <- find_blockchain(blockchain_id),
         {:ok, endpoint} <- rpc_endpoint(blockchain.rpc) do
      name = process_name(blockchain_id)
      Supervisor.start_link(__MODULE__, [blockchain: blockchain, endpoint: endpoint], name: name)
    end
  end

  @spec process_name(blockchain_id) :: atom
  def process_name(id), do: :"#{__MODULE__}_#{id}"

  def init(blockchain: blockchain, endpoint: endpoint) do
    log_subscriptions = Subscriptions.Logs.query(blockchain_id: blockchain.id, enabled: true)

    new_head_subscription =
      Subscriptions.NewHeads.find_by(blockchain_id: blockchain.id, enabled: true)

    children = [
      {NewHeads.NewHeadFetcher,
       blockchain: blockchain, endpoint: endpoint, subscription: new_head_subscription},
      {NewHeads.Timer, blockchain: blockchain},
      {Logs.LogFetcher, blockchain: blockchain, subscriptions: log_subscriptions}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp find_blockchain(id) do
    case Stores.BlockchainStore.find(id) do
      {:ok, _blockchain} = result -> result
      {:error, :not_found} -> {:error, :blockchain_not_found}
    end
  end

  defp rpc_endpoint([]), do: {:error, :rpc_endpoint_not_found}
  defp rpc_endpoint([endpoint | _]), do: {:ok, endpoint}
end
