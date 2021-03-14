defmodule Slurp.NewHeads.NewHeadFetcher.Test do
  use ExUnit.Case

  # defmodule LogResponseHandler do
  #   require Logger

  #   def handle_event([:web, :request, :done], measurements, metadata, _config) do
  #     Logger.info(
  #       "[#{metadata.request_path}] #{metadata.status_code} sent in #{measurements.latency}"
  #     )
  #   end
  # end

  test "polls for new heads at the configured cadence" do
    # :ok =
    #   :telemetry.attach(
    #     # unique handler id
    #     "log-response-handler",
    #     [:web, :request, :done],
    #     &LogResponseHandler.handle_event/4,
    #     nil
    #   )
  end

  test "forwards the new head block number to the log event handler" do
  end
end
