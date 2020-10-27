defmodule RiddlerAdmin.PublishRequests.PublishRequest do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Workspaces

  @id_opts [prefix: "pr", rand_size: 2]

  schema "publish_requests" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]
    field :workspace_id, Ecto.UXID, null: false

    field :status, :string, null: false, default: "pending"
    field :subject, :string, null: false
    field :message, :string
    field :data, :map, null: false

    field :created_by_id, Ecto.UXID

    field :approved_at, :utc_datetime_usec
    field :approved_by_id, Ecto.UXID

    field :published_at, :utc_datetime_usec
    field :published_by_id, Ecto.UXID

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
