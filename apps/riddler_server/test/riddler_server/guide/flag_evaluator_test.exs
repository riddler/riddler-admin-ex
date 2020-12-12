defmodule RiddlerServer.Guide.FlagEvaluatorTest do
  use ExUnit.Case, async: true

  alias RiddlerServer.Guide.Flag
  alias RiddlerServer.Guide.FlagEvaluator

  describe "process converts params" do
    test "converts map to Flag struct" do
      flag_map = %{
        key: "dont_show",
        enabled: false
      }

      assert {"dont_show", "disabled"} = FlagEvaluator.process(flag_map)
    end

    test "converts sub map to Flag.Assigner struct" do
      flag_map = %{
        key: "show_me",
        enabled: true,
        assigners: [
          %{
            type: "Static",
            enabled_treatment: %{
              key: "enabled"
            }
          }
        ]
      }

      assert {"show_me", "enabled"} = FlagEvaluator.process(flag_map)
    end
  end

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
end
