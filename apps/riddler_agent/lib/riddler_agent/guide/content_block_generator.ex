defmodule RiddlerAgent.Guide.ContentBlockGenerator do
  @moduledoc """
  Processes a ContentBlock definition along with a Context to produce a
  map of dynamic content.
  """

  alias RiddlerAgent.Guide.ContentBlock

  require Logger

  def process(%{elements: elements} = content_block, context) when is_map(content_block) and not is_struct(content_block) do
    element_structs =
      elements
      |> Enum.map(fn map -> struct(ContentBlock.Element, map) end)

    converted_map =
      %{content_block | elements: element_structs}

    process(struct(ContentBlock, converted_map), context)
  end

  def process( %ContentBlock{elements: elements} = content_block, _context) do
    generated_elements = 
      elements
    |> Enum.map(fn element ->
      %{key: element.key, text: element.text}
    end)

    %{key: content_block.key, elements: generated_elements}
  end
end
