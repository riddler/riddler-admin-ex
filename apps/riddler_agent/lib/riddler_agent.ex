defmodule RiddlerAgent do
  @moduledoc """
  Module to process logic, and events defined in RiddlerAdmin to generate
  flags.
  """
  alias RiddlerAgent.MemoryStore

  require Logger

  @dev_workspace_id "wsp_01ENQSR6P1FPY0"

  def evaluate(type, key, context \\ %{}) when is_atom(type) and is_binary(key) do
    workspace_id()
    |> storage().get_workspace()
    |> Map.get(type)
    |> Enum.find(fn item -> item.key == key end)
    |> case do
      %{id: "cnd_" <> _other, instructions: instructions} ->
        Logger.info("[AGT] Evaluating #{type} #{key}")

        Predicator.evaluate_instructions!(instructions, context)

      _ ->
        IO.puts("OTHER")
    end
  end

  defp storage(), do: MemoryStore

  defp workspace_id(), do: Confex.get_env(:riddler_agent, :workspace_id, @dev_workspace_id)
end
