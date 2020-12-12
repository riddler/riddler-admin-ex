defmodule RiddlerServer.Guide.FlagEvaluator.RolloutAssignerTest do
  use ExUnit.Case, async: true

  alias RiddlerServer.Guide.Flag
  alias RiddlerServer.Guide.FlagEvaluator

  describe "process rollout assigner" do
    test "flag with rollout assigner returns rollout treatment" do
      flag = %Flag{
        key: "show_me",
        enabled: true,
        assigners: [
          %Flag.Assigner{
            type: "Rollout",
            percentage: 50,
            subject: "user_id",
            custom_salt: "show_me",
            enabled_treatment: %{
              key: "enabled"
            }
          }
        ]
      }

      # This should be refactored to testing the avg of a group
      assert {"show_me", "enabled"} = FlagEvaluator.process(flag, %{"user_id" => 1})
      assert {"show_me", "disabled"} = FlagEvaluator.process(flag, %{"user_id" => 2})
      assert {"show_me", "enabled"} = FlagEvaluator.process(flag, %{"user_id" => 3})
      assert {"show_me", "disabled"} = FlagEvaluator.process(flag, %{"user_id" => 4})
      assert {"show_me", "enabled"} = FlagEvaluator.process(flag, %{"user_id" => 5})
      assert {"show_me", "disabled"} = FlagEvaluator.process(flag, %{"user_id" => 6})
      assert {"show_me", "enabled"} = FlagEvaluator.process(flag, %{"user_id" => 7})
      assert {"show_me", "enabled"} = FlagEvaluator.process(flag, %{"user_id" => 8})
      assert {"show_me", "enabled"} = FlagEvaluator.process(flag, %{"user_id" => 9})
      assert {"show_me", "disabled"} = FlagEvaluator.process(flag, %{"user_id" => 10})
    end
  end
end
