defmodule Messaging do
  @moduledoc """
  Messaging for publishing and subscribing to topics.
  """

  @default_adapter :nsq

  def publish(%{topic_name: topic, payload: payload}) do
    publish(topic, payload)
  end

  def publish(topic, struct) when is_binary(topic) and (is_struct(struct) or is_map(struct)) do
    payload = struct
    |> Jason.encode!()

    adapter().publish(topic, payload)
  end

  def publish(topic, payload) when is_binary(topic) and is_binary(payload) do
    adapter().publish(topic, payload)
  end

  ## === Private Helpers ===

  defp adapter() do
    Confex.get_env(:messaging, :adapter, @default_adapter)
    |> case do
      :nsq -> Messaging.Infra.NSQ
    end
  end
end
