defmodule RiddlerAdmin.Flags.FlagVariant do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Flags.Flag

  @id_opts [prefix: "flva", size: :small]

  @derive {Jason.Encoder, only: [:id, :name, :key, :condition_source, :condition_instructions]}
  schema "flag_variants" do
    field :id, UXID, @id_opts ++ [primary_key: true, autogenerate: true]
    field :rank, :integer

    field :name, :string
    field :key, :string

    field :condition_source, :string
    field :condition_instructions, Ecto.PredicatorInstructions

    belongs_to :flag, Flag

    timestamps()
  end

  def id_opts(), do: @id_opts

  def create_changeset(agent, attrs, flag_id) do
    agent
    |> changeset(attrs)
    |> put_change(:type, "Variant")
    |> put_change(:flag_id, flag_id)
    |> validate_required([:type])
  end

  @doc false
  def changeset(flag_variant, attrs) do
    flag_variant
    |> cast(attrs, [:name, :key, :condition_source])
    |> put_key_change()
    |> validate_required([:name, :key])
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

  defp put_key_change(%{data: %{key: nil}, changes: %{name: name}} = changeset)
       when is_binary(name) do
    key =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9_]/, "_")
      |> String.replace(~r/_+/, "_")

    changeset
    |> put_change(:key, key)
  end

  defp put_key_change(changeset), do: changeset
end
