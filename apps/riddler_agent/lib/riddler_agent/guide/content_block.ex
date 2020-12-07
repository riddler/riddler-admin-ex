defmodule RiddlerAgent.Guide.ContentBlock do
  defstruct [:key, elements: []]

  defmodule __MODULE__.Element do
    defstruct [ :type, :key, :text ]
  end
end
