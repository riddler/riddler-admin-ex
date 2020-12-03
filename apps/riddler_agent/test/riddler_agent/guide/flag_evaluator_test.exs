defmodule RiddlerAgent.Guide.FlagEvaluatorTest do
  use ExUnit.Case, async: true

  alias RiddlerAgent.Guide.FlagEvaluator

  describe "process" do
    test "disabled flag" do
      flag =
        %{key: key, disabled_treatment: disabled_treatment} = %{
          key: "dont_show",
          disabled_treatment: "disabled",
          enabled: false
        }

      assert {^key, ^disabled_treatment} = FlagEvaluator.process(flag)
    end
  end
end
