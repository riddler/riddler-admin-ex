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
            text: text
          }
        ]
      }

      assert %{key: "welcome_message", elements: [%{key: "welcome_message", text: ^text}]} =
               Generator.process(map, %{})
    end
  end

  describe "rendering template" do
    test "text is rendered with context" do
      map = %{
        id: "cbl_WELCOME",
        key: "welcome_message",
        name: "Welcome Message",
        elements: [
          %{
            type: "Text",
            key: "welcome_message",
            text: "Welcome {{ first_name }}!"
          }
        ]
      }

      assert %{
               key: "welcome_message",
               elements: [
                 %{
                   key: "welcome_message",
                   text: "Welcome !"
                 }
               ]
             } = Generator.process(map, %{})

      assert %{
               key: "welcome_message",
               elements: [
                 %{
                   key: "welcome_message",
                   text: "Welcome Bob!"
                 }
               ]
             } = Generator.process(map, %{"first_name" => "Bob"})
    end
  end
end
