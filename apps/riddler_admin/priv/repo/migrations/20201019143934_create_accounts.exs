defmodule RiddlerAdmin.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :id, :text, primary_key: true
      timestamps()
      add :owner_id, references(:identities, on_delete: :restrict), null: false

      add :name, :text, null: false
    end

    create index(:accounts, [:owner_id])
  end
end
