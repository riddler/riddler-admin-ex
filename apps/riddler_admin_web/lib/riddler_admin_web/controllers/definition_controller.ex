defmodule RiddlerAdminWeb.DefinitionController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Definitions

  def index(conn, %{"workspace_id" => workspace_id}) do
    definitions = Definitions.list_workspace_definitions(workspace_id)
    render(conn, "index.html", definitions: definitions, workspace_id: workspace_id)
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    definition = Definitions.get_definition!(id)
    render(conn, "show.html", definition: definition, workspace_id: workspace_id)
  end
end
