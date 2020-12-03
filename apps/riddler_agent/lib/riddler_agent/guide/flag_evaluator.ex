defmodule RiddlerAgent.Guide.FlagEvaluator do
  @moduledoc """
  Processes a Flag definition along with a Context to produce a
  Treatment to use.
  """

  alias RiddlerAgent.Guide
  alias RiddlerAgent.Guide.Flag

  def process(flag), do: process(flag, %{})

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
        %Flag.Assigner{type: "Static", treatment: treatment},
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
