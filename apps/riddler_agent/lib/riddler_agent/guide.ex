defmodule RiddlerAgent.Guide do
  @moduledoc """
  Module to evaluate conditions and flags, render dynamic content,
  and lead participants through their journeys along dynamic paths
  """

  alias __MODULE__.FlagEvaluator

  def evaluate(definition, type, key, context \\ %{})
      when is_map(definition) and is_atom(type) and is_binary(key) do
    definition
    |> Map.get(type)
    |> Enum.find(fn item -> item.key == key end)
    |> case do
      %{id: "cnd_" <> _other, instructions: instructions} ->
        condition_value(instructions, context)

      _ ->
        IO.puts("OTHER")
    end
  end

  def all_flags(definition, context \\ %{}) when is_map(definition) do
    definition
    |> Map.get(:flags)
    |> Enum.filter(fn item ->
      condition_value(item.include_instructions, context)
    end)
    |> Enum.map(&evaluate_flag(&1, context))
    |> Enum.into(%{})
  end

  defdelegate evaluate_flag(flag, context), to: FlagEvaluator, as: :process

  def condition_value(nil, _context), do: true

  def condition_value(instructions, context) do
    case Predicator.evaluate_instructions!(instructions, context) do
      true -> true
      _ -> false
    end
  rescue
    _ -> false
  end
end
