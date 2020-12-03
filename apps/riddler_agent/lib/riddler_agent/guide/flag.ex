defmodule RiddlerAgent.Guide.Flag do
  @default_disabled_treatment "disabled"

  defstruct [:key, :enabled, disabled_treatment: @default_disabled_treatment, activations: []]
end
