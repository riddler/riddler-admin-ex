defmodule RiddlerAgent.Guide.ContentBlockGenerator do
  @moduledoc """
  Processes a ContentBlock definition along with a Context to produce a
  map of dynamic content.
  """

  alias Liquid.Template

  alias RiddlerAgent.Guide.ContentBlock

  require Logger

  def process(%{elements: elements} = content_block, context)
      when is_map(content_block) and not is_struct(content_block) do
    element_structs =
      elements
      |> Enum.map(fn map -> struct(ContentBlock.Element, map) end)

    converted_map = %{content_block | elements: element_structs}

    process(struct(ContentBlock, converted_map), context)
  end

  def process(%ContentBlock{elements: elements} = content_block, context) do
    generated_elements =
      elements
      |> Enum.map(&generate_element(&1, context))

    %{key: content_block.key, elements: generated_elements}
  end

  defp generate_element(element, context) do
    %{key: element.key, text: render_text(element.text, context)}
  end

  defp render_text(text, context) do
    template = Template.parse(text)
    {:ok, rendered, _context} = Template.render(template, context)
    rendered
  end
end
