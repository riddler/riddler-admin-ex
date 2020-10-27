defmodule RiddlerAdminWeb.DefinitionController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Definitions
  alias RiddlerAdmin.Definitions.Definition

  def index(conn, %{"workspace_id" => workspace_id}) do
    definitions = Definitions.list_workspace_definitions(workspace_id)
    render(conn, "index.html", definitions: definitions, workspace_id: workspace_id)
  end

  def new(conn, %{"workspace_id" => workspace_id}) do
    changeset = Definitions.change_definition(%Definition{})

    render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
  end

  def create(conn, %{
        "definition" => definition_params,
        "workspace_id" => workspace_id
      }) do
    case Definitions.create_definition(definition_params, workspace_id) do
      {:ok, definition} ->
        conn
        |> put_flash(:info, "Definition created successfully.")
        |> redirect(
          to:
            Routes.workspace_definition_path(
              conn,
              :show,
              workspace_id,
              definition
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    definition = Definitions.get_definition!(id)
    render(conn, "show.html", definition: definition, workspace_id: workspace_id)
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    definition = Definitions.get_definition!(id)
    changeset = Definitions.change_definition(definition)

    render(conn, "edit.html",
      definition: definition,
      changeset: changeset,
      workspace_id: workspace_id
    )
  end

  def update(conn, %{
        "id" => id,
        "definition" => definition_params,
        "workspace_id" => workspace_id
      }) do
    definition = Definitions.get_definition!(id)

    case Definitions.update_definition(definition, definition_params) do
      {:ok, definition} ->
        conn
        |> put_flash(:info, "Definition updated successfully.")
        |> redirect(to: Routes.workspace_definition_path(conn, :show, workspace_id, definition))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          definition: definition,
          changeset: changeset,
          workspace_id: workspace_id
        )
    end
  end

  def delete(conn, %{"id" => id, "workdspace_id" => workspace_id}) do
    definition = Definitions.get_definition!(id)
    {:ok, _definition} = Definitions.delete_definition(definition)

    conn
    |> put_flash(:info, "Definition deleted successfully.")
    |> redirect(to: Routes.workspace_definition_path(conn, :index, workspace_id))
  end
end
