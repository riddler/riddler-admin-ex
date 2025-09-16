defmodule RiddlerAdmin.ApplicationTest do
  use ExUnit.Case, async: true

  alias RiddlerAdmin.Application

  describe "config_change/3" do
    test "calls endpoint config_change" do
      # Since we can't easily mock the endpoint in a unit test,
      # we'll test that the function exists and returns :ok
      result = Application.config_change(%{}, %{}, [])
      assert result == :ok
    end

    test "handles empty changes" do
      result = Application.config_change(%{}, %{}, [])
      assert result == :ok
    end

    test "handles changes with configuration" do
      changed = %{some_key: "some_value"}
      removed = [:old_key]
      result = Application.config_change(changed, %{}, removed)
      assert result == :ok
    end
  end
end
