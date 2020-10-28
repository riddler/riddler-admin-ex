defmodule RiddlerAdmin.Messaging do
  alias RiddlerAdmin.Event
  alias RiddlerAdmin.Command

  @default_pub_sub_adapter RiddlerAdmin.Infra.Messaging.NSQPubSub

  def publish(topic, payload) when is_binary(topic) do
    pub_sub_adapter().publish(topic, payload)
  end

  def publish(%Command{topic_name: topic, payload: payload}) do
    pub_sub_adapter().publish(topic, payload)
  end

  def record(%Event{topic_name: topic, payload: struct}) when is_struct(struct) do
    payload =
      struct
      |> Jason.encode!()

    pub_sub_adapter().publish(topic, payload)
  end

  def record(%Event{topic_name: topic, payload: payload})
      when is_binary(topic) and is_binary(payload) do
    pub_sub_adapter().publish(topic, payload)
  end

  ## === Private Helpers ===

  defp pub_sub_adapter(),
    do: Confex.get_env(:riddler_admin, :messaging_pub_sub_adapter, @default_pub_sub_adapter)
end
