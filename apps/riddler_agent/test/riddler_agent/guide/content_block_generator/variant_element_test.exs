defmodule RiddlerAgent.Guide.ContentBlockGenerator.VariantElementTest do
  use ExUnit.Case, async: true

  alias RiddlerAgent.Guide.ContentBlockGenerator, as: Generator

  setup do
    content_block = %{
      id: "cbl_WELCOME",
      key: "welcome_message",
      name: "Welcome Message",
      elements: [
        %{
          id: "el_WELCOME_VAR",
          type: "Variant",
          key: "welcome_message",
          name: "Welcome Message",
          elements: [
            %{
              id: "el_WELCOME_USR",
              include_instructions: [["load", "user_id"], ["to_bool"]],
              include_source: "user_id",
              text: "Hi User {{ user_id }}.",
              type: "Text"
            },
            %{
              id: "el_WELCOME_VIS",
              text: "Welcome visitor",
              type: "Text"
            }
          ]
        }
      ]
    }

    {:ok, %{content_block: content_block}}
  end

  describe "Element with 2 variants" do
    test "with no context uses the last element", %{content_block: content_block} do
      result = Generator.process(content_block, %{})

      assert %{key: "welcome_message", elements: [%{key: "welcome_message", text: "Welcome"}]} =
               result

      element = result.elements |> hd

      refute Map.has_key?(element, :elements)
    end
  end
end
