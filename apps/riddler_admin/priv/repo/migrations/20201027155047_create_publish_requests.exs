defmodule RiddlerAdmin.Repo.Migrations.CreatePublishRequests do
  use Ecto.Migration

  def change do
    create table(:publish_requests) do
      add :id, :text, primary_key: true
      timestamps()
      add :approved_at, :utc_datetime_usec
      add :published_at, :utc_datetime_usec

      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      add :created_by_id, references(:identities, on_delete: :nothing)
      add :approved_by_id, references(:identities, on_delete: :nothing)
      add :published_by_id, references(:identities, on_delete: :nothing)

      add :status, :text, null: false
      add :subject, :text, null: false
      add :message, :text
      add :data, :jsonb, null: false
    end

    create index(:publish_requests, [:workspace_id])
    create index(:publish_requests, [:created_by_id])
    create index(:publish_requests, [:approved_by_id])
    create index(:publish_requests, [:published_by_id])
  end
end
