defmodule RiddlerAdminWeb.TelemetryTest do
  use ExUnit.Case, async: true

  alias RiddlerAdminWeb.Telemetry

  describe "start_link/1" do
    test "returns already started when supervisor exists" do
      # The telemetry supervisor is already started by the application
      assert {:error, {:already_started, pid}} = Telemetry.start_link([])
      assert Process.alive?(pid)
    end
  end

  describe "metrics/0" do
    test "returns a list of telemetry metrics" do
      metrics = Telemetry.metrics()
      assert is_list(metrics)
      assert length(metrics) > 0

      # Check that all metrics are structs (from telemetry_metrics)
      Enum.each(metrics, fn metric ->
        assert is_struct(metric)
      end)
    end
  end
end
