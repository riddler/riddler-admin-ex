defmodule RiddlerAdmin.Command do
  defstruct [:topic_name, :payload]

  def new(payload, topic_name) when is_struct(payload) and is_binary(topic_name) do
    %__MODULE__{
      topic_name: topic_name,
      payload: payload
    }
  end
end
