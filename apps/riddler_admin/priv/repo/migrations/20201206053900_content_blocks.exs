defmodule RiddlerAdmin.Repo.Migrations.ContentBlocks do
  use Ecto.Migration

  def change do
    create table(:content_blocks) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :name, :text, null: false
      add :key, :text, null: false
    end

    create index(:content_blocks, [:workspace_id])
  end
end
