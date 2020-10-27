defmodule RiddlerAdmin.Definitions.Definition do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Definitions
  alias RiddlerAdmin.PublishRequests.PublishRequest
  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Workspace

  @current_schema_version 1

  @id_opts [prefix: "def", rand_size: 2]

  schema "definitions" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :schema_version, :integer
    field :version, :integer

    field :data, :map, null: false
    field :yaml, :string, null: false

    belongs_to :workspace, Workspace
    belongs_to :publish_request, PublishRequest

    timestamps()
  end

  def id_opts(), do: @id_opts

  @doc false
  def create_changeset(definition, attrs, workspace_id, publish_request_id) do
    workspace_definition = Workspaces.generate_definition!(workspace_id)

    definition
    |> cast(attrs, [])
    |> put_change(:workspace_id, workspace_id)
    |> put_change(:publish_request_id, publish_request_id)
    |> put_change(:schema_version, @current_schema_version)
    |> put_change(:version, Definitions.next_version(workspace_id))
    |> put_change(:data, workspace_definition)
    |> put_change(:yaml, Ymlr.document!(workspace_definition))
    |> validate_required([:workspace_id, :publish_request_id, :schema_version, :version, :data, :yaml])
    |> unique_constraint([:workspace_id, :version])
    |> unique_constraint([:publish_request_id])
  end
end
