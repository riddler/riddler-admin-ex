defmodule RiddlerAdmin.Flags.FlagTreatment do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Flags.Flag

  @id_opts [prefix: "flgtr", size: :small]

  @derive {Jason.Encoder, only: [:id, :description, :key]}
  schema "flag_treatments" do
    field :id, UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :description, :string
    field :key, :string

    belongs_to :flag, Flag

    timestamps()
  end

  def id_opts(), do: @id_opts

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
