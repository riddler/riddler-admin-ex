defmodule RiddlerAdmin.Flags.Flag do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Workspaces.Workspace

  @id_opts [prefix: "fl", rand_size: 3]

  @derive {Jason.Encoder, only: [:id, :name, :key, :include_source, :include_instructions]}
  schema "flags" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :name, :string
    field :key, :string
    field :type, :string

    field :include_source, :string
    field :include_instructions, Ecto.PredicatorInstructions

    belongs_to :workspace, Workspace

    timestamps()
  end

  def id_opts(), do: @id_opts

  def create_changeset(agent, attrs, workspace_id) do
    agent
    |> changeset(attrs)
    |> put_change(:type, "Variation")
    |> put_change(:workspace_id, workspace_id)
    |> validate_required([:type])
  end

  @doc false
  def changeset(flag, attrs) do
    flag
    |> cast(attrs, [:name, :key, :include_source])
    |> put_key_change()
    |> validate_required([:name, :key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
    |> compile()
  end

  defp compile(changeset) do
    case get_change(changeset, :include_source) do
      nil -> changeset
      source -> compile_instructions(changeset, source)
    end
  end

  defp compile_instructions(changeset, nil), do: changeset

  defp compile_instructions(changeset, source) when is_binary(source),
    do:
      changeset
      |> put_change(:include_instructions, Predicator.compile!(source))

  defp put_key_change(%{data: %{key: nil, name: name}} = changeset) when is_binary(name) do
    key =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9_]/, "")

    changeset
    |> put_change(:key, key)
  end

  defp put_key_change(changeset), do: changeset
end
