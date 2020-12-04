defmodule RiddlerAdmin.Flags.FlagAssigner do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Flags.Flag
  alias RiddlerAdmin.Flags.FlagTreatment

  @id_opts [prefix: "flas", size: :small]

  @derive {Jason.Encoder,
           only: [:id, :type, :enabled_treatment, :condition_source, :condition_instructions]}
  schema "flag_assigners" do
    field :id, UXID, @id_opts ++ [primary_key: true, autogenerate: true]
    field :rank, :integer
    field :type, :string

    belongs_to :enabled_treatment, FlagTreatment, references: :id

    field :condition_source, :string
    field :condition_instructions, Ecto.PredicatorInstructions

    belongs_to :flag, Flag

    timestamps()
  end
end
