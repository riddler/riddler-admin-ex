defmodule RiddlerAdmin.Flags.Flag do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Workspaces.Workspace

  @id_opts [prefix: "fl", rand_size: 3]

  @derive {Jason.Encoder, only: [:id, :key]}
  schema "flags" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :key, :string
    field :type, :string

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
    |> cast(attrs, [:key])
    |> validate_required([:key])
  end
end
