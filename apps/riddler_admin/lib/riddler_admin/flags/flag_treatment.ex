defmodule RiddlerAdmin.Flags.FlagTreatment do
  use RiddlerAdmin.Schema, id_prefix: "flgtr"

  alias RiddlerAdmin.Flags.Flag

  @derive {Jason.Encoder, only: [:id, :description, :key]}
  schema "flag_treatments" do
    field :description, :string
    field :key, :string

    belongs_to :flag, Flag

    timestamps()
  end

  def create_changeset(agent, attrs, flag_id) do
    agent
    |> changeset(attrs)
    |> put_change(:flag_id, flag_id)
  end

  @doc false
  def changeset(flag_treatment, attrs) do
    flag_treatment
    |> cast(attrs, [:description, :key])
    |> validate_required([:key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
  end
end
