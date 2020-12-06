defmodule RiddlerAdmin.Repo.Migrations.Flags do
  use Ecto.Migration

  def change do
    # === Content

    create table(:flags) do
      add :id, :text, primary_key: true
      timestamps()
      add :workspace_id, references(:workspaces, on_delete: :delete_all), null: false

      add :type, :text, null: false
      add :name, :text, null: false
      add :key, :text, null: false

      add :enabled, :boolean, null: false

      add :include_source, :text
      add :include_instructions, :jsonb

      add :disabled_treatment, :text
    end

    create index(:flags, [:workspace_id])
    create unique_index(:flags, [:workspace_id, :key])

    create table(:flag_treatments) do
      add :id, :text, primary_key: true
      timestamps()
      add :flag_id, references(:flags, on_delete: :delete_all), null: false

      add :key, :text, null: false
      add :description, :text
    end

    create index(:flag_treatments, [:flag_id])
    create unique_index(:flag_treatments, [:flag_id, :key])

    create table(:flag_assigners) do
      add :id, :text, primary_key: true
      timestamps()
      add :flag_id, references(:flags, on_delete: :delete_all), null: false
      add :rank, :integer, null: false
      add :type, :text, null: false

      add :subject, :text
      add :custom_salt, :text
      add :percentage, :integer

      add :enabled_treatment_id, references(:flag_treatments, on_delete: :delete_all)

      add :condition_source, :text
      add :condition_instructions, :jsonb
    end

    create index(:flag_assigners, [:flag_id])
    create unique_index(:flag_assigners, [:flag_id, :rank])
  end
end
