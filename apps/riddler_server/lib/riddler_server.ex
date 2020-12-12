defmodule RiddlerServer do
  @moduledoc """
  Module to process logic, and events defined in RiddlerAdmin to generate
  flags.

  This should be moved somewhere else. This code was carried over from
  renaming RiddlerAgent
  """
  alias RiddlerServer.Config
  alias RiddlerServer.Guide
  alias RiddlerServer.MemoryStore

  require Logger

  def generate_content(content_block_key, context) do
    definition()
    |> Guide.generate_content(content_block_key, context)
  end

  def treatment(flag_key, context, default_treatment \\ "disabled") do
    definition()
    |> Guide.treatment(flag_key, context, default_treatment)
  end

  def evaluate(type, key, context \\ %{}) when is_atom(type) and is_binary(key) do
    definition()
    |> Guide.evaluate(type, key, context)
  end

  def all_flags(context \\ %{}) do
    definition()
    |> Guide.all_flags(context)
  end

  def definition() do
    Config.environment_id()
    |> storage().get_environment()
  end

  def store_definition("", _environment_id), do: :ok
  def store_definition(nil, _environment_id), do: :ok

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
