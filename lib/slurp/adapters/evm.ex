defmodule Slurp.Adapters.Evm do
  alias __MODULE__

  @behaviour Slurp.Adapter

  @type event_signature :: Slurp.Adapter.event_signature()
  @type hashed_event_signature :: Slurp.Adapter.hashed_event_signature()
  @type endpoint :: Slurp.Adapter.endpoint()
  @type topic :: Slurp.Adapter.topic()
  @type block_number() :: Slurp.Adapter.block_number()
  @type log_subscription :: Slurp.Logs.LogSubscription.t()
  @type log_filter :: Slurp.Adapter.log_filter()
  @type log :: Slurp.Adapter.log()

  @spec block_number(endpoint) :: {:ok, block_number} | {:error, term}
  def block_number(endpoint) do
    ExW3.block_number(url: endpoint)
  end

  @spec hash_event_signature(event_signature) :: binary
  def hash_event_signature(event_signature) do
    ExW3.Utils.keccak256(event_signature)
  end

  @spec log_hashed_event_signature(log) :: {:ok, hashed_event_signature} | {:error, :not_found}
  def log_hashed_event_signature(log) do
    case log do
      %{"topics" => [hashed_event_signature | _]} -> {:ok, hashed_event_signature}
      _ -> {:error, :not_found}
    end
  end

  @spec deserialize_log_event(log, log_subscription) :: {:ok, struct} | {:error, term}
  def deserialize_log_event(log, log_subscription) do
    [_hashed_event_signature | indexed_topics] = log["topics"]

    log_subscription.abi
    |> Enum.reduce(
      :ok,
      fn
        abi, :ok ->
          with {:ok, _event} = result <-
                 Evm.Abi.deserialize_log_into(log, log_subscription.struct, abi, indexed_topics) do
            result
          else
            {:error, reason} -> {:error, [reason]}
          end

        abi, {:error, reasons} ->
          with {:ok, _event} = result <-
                 Evm.Abi.deserialize_log_into(log, log_subscription.struct, abi, indexed_topics) do
            result
          else
            {:error, reason} -> {:error, [reason | reasons]}
          end

        _abi, {:ok, _} = acc ->
          acc
      end
    )
  end

  @spec get_logs(log_filter, endpoint) :: {:ok, [log]} | {:error, term}
  def get_logs(filter, endpoint) do
    ExW3.get_logs(filter, url: endpoint)
  end
end
