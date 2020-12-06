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

    create table(:elements) do
      add :id, :text, primary_key: true
      timestamps()
      add :content_block_id, references(:content_blocks, on_delete: :delete_all), null: false
      add :rank, :integer, null: false

      add :type, :text, null: false
      add :name, :text, null: false
      add :key, :text, null: false

      add :include_source, :text
      add :include_instructions, :jsonb

      add :text, :text
    end

    create index(:elements, [:content_block_id])
    create unique_index(:elements, [:content_block_id, :rank])
  end
end
