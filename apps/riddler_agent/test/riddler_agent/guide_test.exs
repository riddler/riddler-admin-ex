defmodule RiddlerAgent.GuideTest do
  use ExUnit.Case, async: true

  alias RiddlerAgent.Guide

  describe "treatment" do
    test "returns default_treatment for undefined flag" do
      definition = %{}

      assert "disabled" == Guide.treatment(definition, "anything", %{})
    end

    test "returns treatment for static flag" do
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

      definition = %{flags: [flag_map]}

      assert "enabled" = Guide.treatment(definition, "show_me", %{})
    end
  end
end
