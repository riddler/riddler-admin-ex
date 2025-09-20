defmodule RiddlerAdmin.Repo.Migrations.Genesis do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: [type: :string]) do
      timestamps(type: :utc_datetime_usec)

      add :email, :citext, null: false
      add :hashed_password, :string
      add :confirmed_at, :utc_datetime_usec
      add :sysadmin, :boolean, default: false, null: false
    end

    create unique_index(:users, [:email])
    create index(:users, [:sysadmin])

    create table(:users_tokens, primary_key: [type: :string]) do
      timestamps(type: :utc_datetime_usec, updated_at: false)

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :authenticated_at, :utc_datetime_usec
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create table(:workspaces, primary_key: [type: :string]) do
      timestamps(type: :utc_datetime_usec)

      add :name, :string, null: false
      add :slug, :string, null: false
    end

    create unique_index(:workspaces, [:slug])

    create table(:workspace_memberships, primary_key: [type: :string]) do
      timestamps(type: :utc_datetime_usec)

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false
      add :role, :string, null: false
    end

    create index(:workspace_memberships, [:user_id])
    create index(:workspace_memberships, [:workspace_id])
    create unique_index(:workspace_memberships, [:user_id, :workspace_id])
  end
end
