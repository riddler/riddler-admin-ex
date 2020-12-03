defmodule RiddlerAgent.Guide.FlagEvaluator do
  @moduledoc """
  Processes a Flag definition along with a Context to produce a
  Treatment to use.
  """

  alias RiddlerAgent.Guide

  def process(flag), do: process(flag, %{})

  def process(
        %{enabled: false, key: key, disabled_treatment: disabled_treatment},
        _context
      ),
      do: {key, disabled_treatment}

  def process(
        %{enabled: true, activations: [], key: key, disabled_treatment: disabled_treatment},
        _context
      ),
      do: {key, disabled_treatment}

  def process(
        %{enabled: true, activations: nil, key: key, disabled_treatment: disabled_treatment},
        _context
      ),
      do: {key, disabled_treatment}

  def process(flag, context) do
    disabled_treatment = {flag.key, flag.disabled_treatment}

    case flag do
      %{enabled: false} ->
        disabled_treatment

      _ ->
        flag.treatments
        |> Enum.find_value(disabled_treatment, fn treatment ->
          if Guide.condition_value(treatment.condition_instructions, context) do
            {flag.key, treatment.key}
          end
        end)
    end
  end
end
