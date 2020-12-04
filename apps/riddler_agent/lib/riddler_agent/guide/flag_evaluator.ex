defmodule RiddlerAgent.Guide.FlagEvaluator do
  @moduledoc """
  Processes a Flag definition along with a Context to produce a
  Treatment to use.
  """

  alias RiddlerAgent.Guide
  alias RiddlerAgent.Guide.Flag

  def process(flag), do: process(flag, %{})

  def process(flag, context) when is_map(flag) and not is_struct(flag) do
    converted_map =
      case flag do
        %{assigners: [_at_least_one_assigner] = assigners} ->
          assigner_structs = Enum.map(assigners, fn params ->
            struct(Flag.Assigner, params)
          end)

          %{flag | assigners: assigner_structs}
        _ ->
          flag
      end

    process(struct(Flag, converted_map), context)
  end

  def process(
        %Flag{enabled: false, key: key, disabled_treatment: disabled_treatment},
        _context
      ),
      do: {key, disabled_treatment}

  def process(
        %Flag{enabled: true, assigners: [], key: key, disabled_treatment: disabled_treatment},
        _context
      ),
      do: {key, disabled_treatment}

  def process(
        %Flag{
          enabled: true,
          assigners: assigners
        } = flag,
        context
      ) do
    assigners
    |> Enum.find(fn %{condition_instructions: instructions} ->
      Guide.condition_value(instructions, context)
    end)
    |> treatment_for_assigner(flag)
  end

  def treatment_for_assigner(
        %Flag.Assigner{type: "Static", enabled_treatment: %{key: treatment}},
        %Flag{key: key}
      ) do
    {key, treatment}
  end

  def treatment_for_assigner(_assigner, %Flag{
        key: key,
        disabled_treatment: disabled_treatment
      }) do
    {key, disabled_treatment}
  end
end
