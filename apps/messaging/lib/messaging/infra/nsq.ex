defmodule Messaging.Infra.NSQ do
  alias Messaging.Behaviour, as: MessagingBehaviour
  alias Messaging.Infra.NSQ.Server, as: NSQServer

  @behaviour MessagingBehaviour

  @doc """
  Publish a NSQ message to a NSQ topic
  """
  @impl MessagingBehaviour
  def publish(topic, message) do
    NSQServer.publish(topic, message)
  end
end
