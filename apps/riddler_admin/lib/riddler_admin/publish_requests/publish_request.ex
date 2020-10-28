defmodule RiddlerAdmin.PublishRequests.PublishRequest do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Workspace
  alias RiddlerAdmin.Identities.Identity

  @id_opts [prefix: "pr", rand_size: 2]

  schema "publish_requests" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :status, :string, null: false, default: "pending"
    field :subject, :string, null: false
    field :message, :string
    field :data, :map, null: false

    field :approved_at, :utc_datetime_usec
    field :published_at, :utc_datetime_usec

    belongs_to :workspace, Workspace
    belongs_to :created_by, Identity
    belongs_to :approved_by, Identity
    belongs_to :published_by, Identity

    timestamps()
  end

  def id_opts(), do: @id_opts

  @doc false
  def create_changeset(publish_request, attrs, workspace_id, author_id) do
    workspace_definition = Workspaces.generate_definition!(workspace_id)

    publish_request
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
    |> put_change(:created_by_id, author_id)
    |> put_change(:status, "pending")
    |> put_change(:data, workspace_definition)
    |> validate_required([:workspace_id, :created_by_id])
  end

  @doc false
  def changeset(publish_request, attrs) do
    publish_request
    |> cast(attrs, [:subject, :message])
    |> validate_required([:subject])
  end
end
