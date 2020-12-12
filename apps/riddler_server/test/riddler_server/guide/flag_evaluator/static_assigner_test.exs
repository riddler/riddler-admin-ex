defmodule RiddlerServer.Guide.FlagEvaluator.StaticAssignerTest do
  use ExUnit.Case, async: true

  alias RiddlerServer.Guide.Flag
  alias RiddlerServer.Guide.FlagEvaluator

  describe "process static assigner" do
    test "flag with static assigner returns static treatment" do
      flag = %Flag{
        key: "show_me",
        enabled: true,
        assigners: [
          %Flag.Assigner{
            type: "Static",
            enabled_treatment: %{
              key: "enabled"
            }
          }
        ]
      }

      assert {"show_me", "enabled"} = FlagEvaluator.process(flag)
    end

    test "multiple assigners uses the first to evaluate to true" do
      flag = %Flag{
        key: "show_me",
        enabled: true,
        assigners: [
          %Flag.Assigner{
            condition_instructions: [["lit", false]],
            type: "Static",
            enabled_treatment: %{
              key: "not_this"
            }
          },
          %Flag.Assigner{
            type: "Static",
            enabled_treatment: %{
              key: "enabled"
            }
          }
        ]
      }

      assert {"show_me", "enabled"} = FlagEvaluator.process(flag)
    end
  end
end
