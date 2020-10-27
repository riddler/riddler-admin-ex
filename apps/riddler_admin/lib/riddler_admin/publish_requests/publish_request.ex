defmodule RiddlerAdmin.PublishRequests.PublishRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "publish_requests" do
    field :approved_at, :utc_datetime_usec
    field :message, :string
    field :published_at, :utc_datetime_usec
    field :status, :string
    field :subject, :string
    field :workspace_id, :id
    field :approved_by_identity_id, :id

    timestamps()
  end

  @doc false
  def changeset(publish_request, attrs) do
    publish_request
    |> cast(attrs, [:approved_at, :published_at, :status, :subject, :message])
    |> validate_required([:approved_at, :published_at, :status, :subject, :message])
  end
end
