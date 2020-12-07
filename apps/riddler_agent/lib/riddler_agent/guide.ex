defmodule RiddlerAgent.Guide do
  @moduledoc """
  Module to evaluate conditions and flags, render dynamic content,
  and lead participants through their journeys along dynamic paths
  """

  alias __MODULE__.ContentBlockGenerator
  alias __MODULE__.FlagEvaluator

  defdelegate evaluate_flag(flag, context), to: FlagEvaluator, as: :process

  defdelegate generate_block(content_block, context), to: ContentBlockGenerator, as: :process

  @doc """
  Returns the generated content for a Content Block.
  """
  def generate_content(definition, content_block_key, context) do
    item_by_type_and_key(definition, :content_blocks, content_block_key)
    |> case do
      content_block when is_map(content_block) ->
        generate_block(content_block, context)
      nil ->
        nil
    end
  end

  @doc """
  Returns the treatment to be used for the flag key.
  """
  def treatment(definition, flag_key, context, default_treatment \\ "disabled") do
    item_by_type_and_key(definition, :flags, flag_key)
    |> case do
      flag when is_map(flag) ->
        {_key, treatment} = evaluate_flag(flag, context)
        treatment
      nil ->
        default_treatment
    end

  rescue
    _ ->
    default_treatment
  end

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

  def condition_value(nil, _context), do: true

  def condition_value(instructions, context) do
    case Predicator.evaluate_instructions!(instructions, context) do
      true -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  defp item_by_type_and_key(definition, type, key)
      when is_map(definition) and is_atom(type) and is_binary(key) do
    definition
    |> Map.get(type)
    |> Enum.find(fn item -> item.key == key end)
  end
end
