defmodule RiddlerAdmin.Flags.FlagAssigner do
  use RiddlerAdmin.Schema, id_prefix: "flgasn"

  alias RiddlerAdmin.Flags.Flag
  alias RiddlerAdmin.Flags.FlagTreatment

  @derive {Jason.Encoder,
           only: [
             :id,
             :type,
             :enabled_treatment,
             :condition_source,
             :condition_instructions,
             :subject,
             :custom_salt,
             :percentage
           ]}
  schema "flag_assigners" do
    field :rank, :integer
    field :type, :string

    field :subject, :string
    field :custom_salt, :string
    field :percentage, :integer

    belongs_to :enabled_treatment, FlagTreatment, references: :id

    field :condition_source, :string
    field :condition_instructions, Ecto.PredicatorInstructions

    belongs_to :flag, Flag

    timestamps()
  end

  def create_changeset(flag_assigner, attrs, flag_id) do
    flag_assigner
    |> changeset(attrs)
    |> put_change(:flag_id, flag_id)
  end

  @doc false
  def changeset(flag_assigner, attrs) do
    flag_assigner
    |> cast(attrs, [
      :type,
      :rank,
      :enabled_treatment_id,
      :condition_source,
      :subject,
      :percentage,
      :custom_salt
    ])
    |> compile()
    |> validate_required([:type, :rank])
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
