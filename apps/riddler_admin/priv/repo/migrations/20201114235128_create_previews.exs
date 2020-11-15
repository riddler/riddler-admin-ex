defmodule RiddlerAdmin.Repo.Migrations.CreatePreviews do
  use Ecto.Migration

  def change do
    create table(:previews) do
      add :id, :text, primary_key: true
      timestamps()

      add :workspace_id, references(:workspaces, on_delete: :delete_all)
      add :definition_id, references(:definitions, on_delete: :delete_all)
    end

    create index(:previews, [:workspace_id])
    create index(:previews, [:definition_id])
  end
end
