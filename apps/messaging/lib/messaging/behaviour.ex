defmodule Messaging.Behaviour do
  @moduledoc """
  TODO: Messaging Behaviour
  """

  # TODO: Add more types
  @typedoc """
  Topic ....
  """
  @type topic :: String.t()

  @typedoc """
  Payload ....
  """
  @type payload :: String.t()

  @typedoc """
  Result ....
  """
  @type publish_result :: :ok | {:error, String.t()}

  @doc """
  Publish a message to a topic
  """
  @callback publish(topic :: topic, payload :: payload) :: publish_result
end
