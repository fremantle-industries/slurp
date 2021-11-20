defmodule Slurp.Logs do
  @type log_subscription_config :: map
  @type blockchain :: Slurp.Blockchains.Blockchain.t()
  @type log_subscription :: Slurp.Logs.LogSubscription.t()
  @type invalid_config :: Slurp.Logs.LoadSubscriptions.invalid_config()

  @spec load_subscriptions([blockchain], map) :: {:ok, [log_subscription]} | {:error, invalid_config}
  def load_subscriptions(blockchains, config \\ Application.get_env(:slurp, :log_subscriptions, %{})) do
    Slurp.Logs.LoadSubscriptions.load(blockchains, config)
  end
end
