defmodule RiddlerAgent.Guide.FlagEvaluatorTest do
  use ExUnit.Case, async: true

  alias RiddlerAgent.Guide.Flag
  alias RiddlerAgent.Guide.FlagEvaluator

  describe "process" do
    test "disabled flag returns the default disabled treatment" do
      flag =
        %{key: key, disabled_treatment: disabled_treatment} = %Flag{
          key: "dont_show",
          enabled: false
        }

      assert {^key, ^disabled_treatment} = FlagEvaluator.process(flag)
    end

    test "disabled flag returns a custom disabled treatment" do
      flag =
        %{key: key, disabled_treatment: disabled_treatment} = %{
          key: "dont_show",
          disabled_treatment: "nope",
          enabled: false
        }

      assert {^key, ^disabled_treatment} = FlagEvaluator.process(flag)
    end

    test "enabled flag with no activations returns the disabled treatment" do
      flag =
        %{key: key, disabled_treatment: disabled_treatment} = %Flag{
          key: "dont_show",
          disabled_treatment: "disabled",
          enabled: true
        }

      assert {^key, ^disabled_treatment} = FlagEvaluator.process(flag)
    end
  end
end
