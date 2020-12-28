defmodule Slurp.Adapter do
  @type endpoint :: String.t()

  @type latest_block_number :: String.t()
  @type earliest_block_number :: String.t()
  @type pending_block_number :: String.t()
  @type hex_block_number :: String.t()
  @type block_number :: non_neg_integer()

  @type event_signature :: String.t()
  @type hashed_event_signature :: String.t()
  @type topic :: String.t()
  @type log_subscription :: Slurp.Logs.LogSubscription.t()
  @type log :: map
  @type log_filter :: %{
          optional(:address) => String.t(),
          optional(:fromBlock) =>
            hex_block_number | latest_block_number | earliest_block_number | pending_block_number,
          optional(:toBlock) =>
            hex_block_number | latest_block_number | earliest_block_number | pending_block_number,
          optional(:topics) => [String.t()],
          optional(:blockhash) => String.t()
        }

  @callback block_number(endpoint) :: {:ok, block_number} | {:error, term}
  @callback hash_event_signature(event_signature) :: hashed_event_signature
  @callback log_hashed_event_signature(log) ::
              {:ok, hashed_event_signature} | {:error, term}
  @callback deserialize_log_event(log, log_subscription) :: {:ok, struct} | {:error, term}
  @callback get_logs(map, endpoint) :: {:ok, list} | {:error, term}

  # TODO: record start/end telemetry
  def block_number(blockchain, endpoint) do
    # :telemetry.execute(
    #   [:slurp, :adapter, :request, :start],
    #   %{latency: 1},
    #   %{function: :block_number, blockchain_id: state.blockchain.id, poll_interval_ms: state.blockchain.poll_interval_ms}
    # )

    result = blockchain.adapter.block_number(endpoint)

    # :telemetry.execute(
    #   [:slurp, :adapter, :request, :end],
    #   %{latency: 2},
    #   %{function: :block_number, blockchain_id: state.blockchain.id, poll_interval_ms: state.blockchain.poll_interval_ms}
    # )

    result
  end

  def hash_event_signature(blockchain, event_signature) do
    blockchain.adapter.hash_event_signature(event_signature)
  end

  def log_hashed_event_signature(blockchain, log) do
    blockchain.adapter.log_hashed_event_signature(log)
  end

  def deserialize_log_event(blockchain, log, log_subscription) do
    blockchain.adapter.deserialize_log_event(log, log_subscription)
  end

  # TODO: record start/end telemetry
  def get_logs(blockchain, filter, endpoint) do
    blockchain.adapter.get_logs(filter, endpoint)
  end
end
