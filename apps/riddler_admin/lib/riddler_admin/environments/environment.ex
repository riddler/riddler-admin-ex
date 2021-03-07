defmodule RiddlerAdmin.Environments.Environment do
  use RiddlerAdmin.Schema, id_prefix: "env"

  alias RiddlerAdmin.Definitions.Definition
  alias RiddlerAdmin.Workspaces.Workspace

  @derive {Jason.Encoder, only: [:id, :name, :key]}
  schema "environments" do
    field :name, :string
    field :key, :string

    belongs_to :definition, Definition
    belongs_to :workspace, Workspace

    timestamps()
  end

  def create_changeset(agent, attrs, workspace_id) do
    agent
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
  end

  @doc false
  def changeset(flag, attrs) do
    flag
    |> cast(attrs, [:name, :key, :definition_id])
    |> put_key_change()
    |> validate_required([:name, :key])
    |> validate_format(:key, ~r/^[a-z][a-z0-9_]+$/)
  end

  defp put_key_change(%{data: %{key: nil}, changes: %{name: name}} = changeset)
       when is_binary(name) do
    key =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9_]/, "_")
      |> String.replace(~r/_+/, "_")

    changeset
    |> put_change(:key, key)
  end

  defp put_key_change(changeset), do: changeset
end
