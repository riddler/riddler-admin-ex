defmodule RiddlerServer.Guide.FlagEvaluator do
  @moduledoc """
  Processes a Flag definition along with a Context to produce a
  Treatment to use.
  """

  alias RiddlerServer.Guide
  alias RiddlerServer.Guide.Flag

  require Logger

  def process(flag), do: process(flag, %{})

  def process(flag, context) when is_map(flag) and not is_struct(flag) do
    converted_map =
      case flag do
        %{assigners: [_at_least_one_assigner] = assigners} ->
          assigner_structs =
            Enum.map(assigners, fn params ->
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
    |> treatment_for_assigner(flag, context)
  end

  def treatment_for_assigner(
        %Flag.Assigner{type: "Static", enabled_treatment: %{key: treatment}},
        %Flag{key: key},
        _context
      ) do
    {key, treatment}
  end

  def treatment_for_assigner(
        %Flag.Assigner{type: "Rollout", subject: subject_key},
        %Flag{key: key, disabled_treatment: disabled_treatment},
        _context
      )
      when is_nil(subject_key) do
    Logger.debug("[RSRV] Subject key is nil")
    {key, disabled_treatment}
  end

  def treatment_for_assigner(
        %Flag.Assigner{
          type: "Rollout",
          percentage: rollout_percentage,
          subject: subject_key,
          custom_salt: custom_salt,
          enabled_treatment: %{key: enabled_treatment}
        },
        %Flag{key: key, disabled_treatment: disabled_treatment},
        context
      ) do
    subject =
      case Map.has_key?(context, subject_key) do
        true ->
          Map.get(context, subject_key)

        false ->
          Logger.warn("[RSRV] Subject key '#{subject_key}' not found in context")
          "NEED_BETTER_DEFAULT_SUBJECT"
      end

    salt_group = custom_salt || key
    hash_string = "#{salt_group}:#{subject}"
    hash_value = Murmur.hash_x86_32(hash_string)
    hash_percentage = rem(hash_value, 100)

    case hash_percentage < rollout_percentage do
      true ->
        {key, enabled_treatment}

      false ->
        {key, disabled_treatment}
    end
  end

  def treatment_for_assigner(
        _assigner,
        %Flag{
          key: key,
          disabled_treatment: disabled_treatment
        },
        _context
      ) do
    {key, disabled_treatment}
  end
end
