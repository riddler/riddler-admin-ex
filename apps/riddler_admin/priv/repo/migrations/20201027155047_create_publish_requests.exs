defmodule RiddlerAdmin.Repo.Migrations.CreatePublishRequests do
  use Ecto.Migration

  def change do
    create table(:publish_requests) do
      add :approved_at, :utc_datetime_usec
      add :published_at, :utc_datetime_usec
      add :status, :text
      add :subject, :text
      add :message, :text
      add :workspace_id, references(:workspaces, on_delete: :nothing)
      add :approved_by_identity_id, references(:identities, on_delete: :nothing)

      timestamps()
    end

    create index(:publish_requests, [:workspace_id])
    create index(:publish_requests, [:approved_by_identity_id])
  end
end
