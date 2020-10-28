defmodule RiddlerAdmin.Repo.Migrations.CreateFlags do
  use Ecto.Migration

  def change do
    create table(:flags) do
      add :key, :text
      add :type, :text
      add :workspace_id, references(:workspaces, on_delete: :nothing)

      timestamps()
    end

    create index(:flags, [:workspace_id])
  end
end
