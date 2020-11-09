defmodule RiddlerAdmin.PublishRequests.PublishRequest do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Definitions.Definition
  alias RiddlerAdmin.Identities.Identity
  alias RiddlerAdmin.Workspaces
  alias RiddlerAdmin.Workspaces.Workspace

  @id_opts [prefix: "pr", rand_size: 2]

  @derive {Jason.Encoder, only: [:id, :data, :workspace_id, :subject]}
  schema "publish_requests" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]

    field :status, :string, null: false, default: "pending"
    field :subject, :string, null: false
    field :message, :string
    field :data, :map, null: false

    field :approved_at, :utc_datetime_usec
    field :published_at, :utc_datetime_usec

    belongs_to :definition, Definition
    belongs_to :workspace, Workspace
    belongs_to :created_by, Identity
    belongs_to :approved_by, Identity
    belongs_to :published_by, Identity

    timestamps()
  end

  def id_opts(), do: @id_opts

  def create_changeset(publish_request, attrs, workspace_id, author_id) do
    publish_request
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
    |> put_change(:created_by_id, author_id)
    |> put_change(:status, "Pending Approval")
    |> validate_required([:workspace_id, :created_by_id])
  end

  @doc false
  def changeset(publish_request, attrs) do
    publish_request
    |> cast(attrs, [:subject, :message])
    |> validate_required([:subject])
  end

  def approve_changeset(publish_request, approver_id) do
    publish_request
    |> cast(%{}, [])
    |> put_change(:approved_by_id, approver_id)
    |> put_change(:approved_at, DateTime.utc_now())
    |> put_change(:status, "Approved")
    |> validate_required([:approved_by_id, :approved_at])
  end

  def publish_changeset(publish_request, publisher_id) do
    publish_request
    |> cast(%{}, [])
    |> put_change(:published_by_id, publisher_id)
    |> put_change(:published_at, DateTime.utc_now())
    |> put_change(:status, "Published")
    |> validate_required([:published_by_id, :published_at])
  end
end
