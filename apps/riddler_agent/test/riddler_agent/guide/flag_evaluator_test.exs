defmodule RiddlerAgent.Guide.FlagEvaluatorTest do
  use ExUnit.Case, async: true

  alias RiddlerAgent.Guide.Flag
  alias RiddlerAgent.Guide.FlagEvaluator

  describe "process disabled" do
    test "disabled flag returns the default disabled treatment" do
      flag = %Flag{
        key: "dont_show",
        enabled: false
      }

      assert {"dont_show", "disabled"} = FlagEvaluator.process(flag)
    end

    test "disabled flag returns a custom disabled treatment" do
      flag = %Flag{
        key: "dont_show",
        disabled_treatment: "nope",
        enabled: false
      }

      assert {"dont_show", "nope"} = FlagEvaluator.process(flag)
    end

    test "enabled flag with no assigners returns the disabled treatment" do
      flag = %Flag{
        key: "dont_show",
        enabled: true
      }

      assert {"dont_show", "disabled"} = FlagEvaluator.process(flag)
    end
  end

  describe "process static assigner" do
    test "flag with static assigner returns static treatment" do
      flag = %Flag{
        key: "show_me",
        enabled: true,
        assigners: [
          %Flag.Assigner{
            type: "Static",
            treatment: "enabled"
          }
        ]
      }

      assert {"show_me", "enabled"} = FlagEvaluator.process(flag)
    end
  end
end
