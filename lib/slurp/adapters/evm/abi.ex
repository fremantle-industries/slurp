defmodule Slurp.Adapters.Evm.Abi do
  alias __MODULE__

  def indexed_event_attr_names(%{"inputs" => inputs}) do
    inputs
    |> Enum.filter(fn %{"indexed" => indexed} -> indexed end)
    |> Enum.map(fn %{"name" => name} -> name |> Macro.underscore() end)
    |> Enum.map(&String.to_atom/1)
  end

  def indexed_event_types(%{"inputs" => inputs}) do
    inputs
    |> Enum.filter(fn %{"indexed" => indexed} -> indexed end)
    |> Enum.map(fn %{"type" => type} -> "(#{type})" end)
  end

  def non_indexed_event_attr_names(%{"inputs" => inputs}) do
    inputs
    |> Enum.filter(fn %{"indexed" => indexed} -> !indexed end)
    |> Enum.map(fn %{"name" => name} -> name |> Macro.underscore() end)
    |> Enum.map(&String.to_atom/1)
  end

  def non_indexed_event_signature(%{"name" => event_name, "inputs" => inputs}) do
    non_indexed_types =
      inputs
      |> Enum.filter(fn %{"indexed" => indexed} -> !indexed end)
      |> Enum.map(fn %{"type" => type} -> type end)

    "#{event_name}(#{Enum.join(non_indexed_types, ",")})"
  end

  def deserialize_log_into(log, event_mapping, indexed_topics) do
    {struct, abi} = event_mapping
    topic_event_attr_names = Abi.indexed_event_attr_names(abi)
    topic_event_types = Abi.indexed_event_types(abi)
    log_data_event_attr_names = Abi.non_indexed_event_attr_names(abi)
    log_data_event_signature = Abi.non_indexed_event_signature(abi)

    try do
      topic_event_values =
        indexed_topics
        |> Enum.zip(topic_event_types)
        |> Enum.map(fn {indexed_topic, topic_type} ->
          {decoded} = ExW3.Abi.decode_data(topic_type, indexed_topic)
          decoded
        end)

      indexed_fields =
        topic_event_attr_names
        |> Enum.zip(topic_event_values)
        |> Enum.into(%{})

      log_data_event_values = ExW3.Abi.decode_event(log["data"], log_data_event_signature)

      non_indexed_fields =
        log_data_event_attr_names
        |> Enum.zip(log_data_event_values)
        |> Enum.into(%{})

      event = struct!(struct, Map.merge(indexed_fields, non_indexed_fields))

      {:ok, event}
    rescue
      error ->
        {:error, {error, __STACKTRACE__}}
    end
  end
end
