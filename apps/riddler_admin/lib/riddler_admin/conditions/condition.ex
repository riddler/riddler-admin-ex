defmodule RiddlerAdmin.Conditions.Condition do
  use RiddlerAdmin.Schema

  schema "conditions" do
    field :id, Ecto.UXID, primary_key: true, autogenerate: true, prefix: "cnd", rand_size: 8
    field :account_id, Ecto.UXID

    field :key, :string
    field :source, :string
    field :instructions, Ecto.PredicatorInstructions

    timestamps()
  end

  @doc false
  def changeset(condition, attrs) do
    condition
    |> cast(attrs, [:key, :source])
    |> validate_required([:key, :source])
    # |> validate_source(source)
    |> compile()
  end

  @doc false
  def create_changeset(condition, attrs, account_id) do
    condition
    |> changeset(attrs)
    |> put_change(:account_id, account_id)
    |> validate_required([:account_id])
  end

  defp compile(changeset) do
    case get_change(changeset, :source) do
      nil -> changeset
      source -> compile_instructions(changeset, source)
    end
  end

  defp compile_instructions(changeset, nil), do: changeset

  defp compile_instructions(changeset, source) when is_binary(source),
    do:
      changeset
      |> put_change(:instructions, Predicator.compile!(source))
end
