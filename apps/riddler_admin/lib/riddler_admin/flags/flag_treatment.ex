defmodule RiddlerAdmin.Flags.FlagTreatment do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Flags.Flag

  @id_opts [prefix: "fltr", size: :small]

  @derive {Jason.Encoder, only: [:id, :description, :key]}
  schema "flag_treatments" do
    field :id, UXID, @id_opts ++ [primary_key: true, autogenerate: true]
    field :rank, :integer

    field :description, :string
    field :key, :string

    belongs_to :flag, Flag

    timestamps()
  end

  def id_opts(), do: @id_opts

  def create_changeset(agent, attrs, flag_id) do
    agent
    |> changeset(attrs)
    |> put_change(:type, "Treatment")
    |> put_change(:flag_id, flag_id)
    |> validate_required([:type])
  end

  @doc false
  def changeset(flag_treatment, attrs) do
    flag_treatment
    |> cast(attrs, [:description, :key, :condition_source])
    |> validate_required([:key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
    |> compile()
  end

  defp compile(changeset) do
    case get_change(changeset, :condition_source) do
      nil -> changeset
      source -> compile_instructions(changeset, source)
    end
  end

  defp compile_instructions(changeset, nil), do: changeset

  defp compile_instructions(changeset, source) when is_binary(source),
    do:
      changeset
      |> put_change(:condition_instructions, Predicator.compile!(source))
end
