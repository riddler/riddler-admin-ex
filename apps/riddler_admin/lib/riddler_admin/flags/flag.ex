defmodule RiddlerAdmin.Flags.Flag do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Workspaces.Workspace

  @id_opts [prefix: "fl", rand_size: 3]

  @derive {Jason.Encoder, only: [:id, :key, :include_source, :include_instructions]}
  schema "flags" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

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
    |> cast(attrs, [:key, :include_source])
    # |> validate_source(source)
    |> compile()
    |> validate_required([:key])
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
end
