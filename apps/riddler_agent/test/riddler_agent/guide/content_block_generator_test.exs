defmodule RiddlerAgent.Guide.ContentBlockGeneratorTest do
  use ExUnit.Case, async: true

  alias RiddlerAgent.Guide.ContentBlockGenerator, as: Generator

  describe "process converts params" do
    test "converts map to ContentBlock struct" do
      text = "Welcome to this awesome sauce!"
      map = %{
        id: "cbl_WELCOME",
        key: "welcome_message",
        name: "Welcome Message",
        elements: [
          %{
            type: "Text",
            key: "welcome_message",
            text: text,
          }
        ]
      }

      assert %{key: "welcome_message", elements: [%{key: "welcome_message", text: ^text}]} = Generator.process(map, %{})
    end
  end
end
