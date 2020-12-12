defmodule RiddlerServer.Guide.Flag do
  @default_disabled_treatment "disabled"

  defstruct [:key, :enabled, disabled_treatment: @default_disabled_treatment, assigners: []]

  defmodule __MODULE__.Assigner do
    defstruct [
      :type,
      :enabled_treatment,
      :condition_source,
      :condition_instructions,
      :percentage,
      :subject,
      :custom_salt
    ]
  end
end
