defmodule RiddlerAgent.Messaging.Consumers.DefinitionConsumer do
  alias RiddlerAgent.MemoryStore

  require Logger

  def handle_message(body, %{attempts: _attempts, id: _message_id, timestamp: _timestamp}) do
    with %{"yaml" => yaml} <- Jason.decode!(body),
         map = YamlElixir.read_from_string!(yaml, atoms: true) do
      Logger.info("[AGT] Received Definition #{map["id"]}")

      map
      |> to_atom_map()
      |> storage().add_definition()

      :ok
    end
  end

  defp to_atom_map(map) when is_map(map),
    do: Map.new(map, fn {k, v} -> {String.to_atom(k), to_atom_map(v)} end)

  defp to_atom_map(list) when is_list(list),
    do: Enum.map(list, fn v -> to_atom_map(v) end)

  defp to_atom_map(v), do: v

  defp storage(), do: MemoryStore
end
