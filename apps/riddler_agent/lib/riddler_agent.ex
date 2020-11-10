defmodule RiddlerAgent do
  @moduledoc """
  Module to process logic, and events defined in RiddlerAdmin to generate
  flags.
  """
  alias RiddlerAgent.Config
  alias RiddlerAgent.MemoryStore

  require Logger

  def evaluate(type, key, context \\ %{}) when is_atom(type) and is_binary(key) do
    Config.environment_id()
    |> storage().get_environment()
    |> Map.get(type)
    |> Enum.find(fn item -> item.key == key end)
    |> case do
      %{id: "cnd_" <> _other, instructions: instructions} ->
        Logger.info("[AGT] Evaluating #{type} #{key}")

        condition_value(instructions, context)

      _ ->
        IO.puts("OTHER")
    end
  end

  def all_flags(context \\ %{}) do
    Logger.info("[AGT] Generating all flags")

    Config.environment_id()
    |> storage().get_environment()
    |> Map.get(:flags)
    |> Enum.filter(fn item ->
      item.include_instructions
      |> case do
        nil -> true
        instructions -> condition_value(instructions, context)
      end
    end)
    |> Enum.map(fn item ->
      {item.key, true}
    end)
    |> Enum.into(%{})
  end

  defp condition_value(instructions, context) do
    case Predicator.evaluate_instructions!(instructions, context) do
      true -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  def store_definition(yaml, environment_id) do
    map = YamlElixir.read_from_string!(yaml, atoms: true)

    map
    |> to_atom_map()
    |> storage().add_definition(environment_id)

    :ok
  end

  defp to_atom_map(map) when is_map(map),
    do: Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_map(v)} end)

  defp to_atom_map(list) when is_list(list),
    do: Enum.map(list, fn v -> to_atom_map(v) end)

  defp to_atom_map(v), do: v

  defp storage(), do: MemoryStore
end
