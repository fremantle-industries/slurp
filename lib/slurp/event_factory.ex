defmodule Slurp.EventFactory do
  @type event_signature :: Slurp.Adapter.event_signature()
  @type log_subscription_config :: Slurp.Logs.LogSubscription.config()
  @type log_subscription_config_tuple :: {event_signature, [log_subscription_config]}

  def get_opt(opts, name, default) do
    Keyword.get(opts, name) || default
  end

  def handler_config(enabled: enabled, event_mappings: event_mappings, handler: handler) do
    %{
      enabled: enabled,
      handler: handler,
      event_mappings: event_mappings
    }
  end
end
