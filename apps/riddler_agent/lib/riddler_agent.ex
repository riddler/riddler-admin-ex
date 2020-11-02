defmodule RiddlerAgent do
  @moduledoc """
  Module to process logic, and events defined in RiddlerAdmin to generate
  flags.
  """
  alias RiddlerAgent.Config
  alias RiddlerAgent.MemoryStore

  require Logger

  def evaluate(type, key, context \\ %{}) when is_atom(type) and is_binary(key) do
    Config.workspace_id()
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

  def all_flags(context \\ %{}) do
    Logger.info("[AGT] Generating all flags")

    Config.workspace_id()
    |> storage().get_workspace()
    |> Map.get(:flags)
    |> Enum.filter(fn item ->
      item.include_instructions
      |> case do
        nil -> true
        instructions -> Predicator.evaluate_instructions!(instructions, context)
      end
    end)
    |> Enum.map(fn item ->
      {item.key, true}
    end)
    |> Enum.into(%{})
  end

  defp storage(), do: MemoryStore
end
