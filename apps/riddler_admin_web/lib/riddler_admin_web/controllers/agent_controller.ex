defmodule RiddlerAdminWeb.AgentController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Agents
  alias RiddlerAdmin.Agents.Agent

  def index(conn, %{"workspace_id" => workspace_id, "environment_id" => environment_id}) do
    agents = Agents.list_environment_agents(environment_id)

    render(conn, "index.html",
      agents: agents,
      workspace_id: workspace_id,
      environment_id: environment_id
    )
  end

  def new(conn, %{"workspace_id" => workspace_id, "environment_id" => environment_id}) do
    changeset = Agents.change_agent(%Agent{})

    render(conn, "new.html",
      changeset: changeset,
      workspace_id: workspace_id,
      environment_id: environment_id
    )
  end

  def create(conn, %{
        "agent" => agent_params,
        "workspace_id" => workspace_id,
        "environment_id" => environment_id
      }) do
    case Agents.create_agent(agent_params, environment_id) do
      {:ok, agent} ->
        conn
        |> put_flash(:info, "Agent created successfully.")
        |> redirect(
          to:
            Routes.workspace_environment_agent_path(
              conn,
              :show,
              workspace_id,
              environment_id,
              agent
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html",
          changeset: changeset,
          workspace_id: workspace_id,
          environment_id: environment_id
        )
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id, "environment_id" => environment_id}) do
    agent = Agents.get_agent!(id)

    render(conn, "show.html",
      agent: agent,
      workspace_id: workspace_id,
      environment_id: environment_id
    )
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id, "environment_id" => environment_id}) do
    agent = Agents.get_agent!(id)
    changeset = Agents.change_agent(agent)

    render(conn, "edit.html",
      agent: agent,
      changeset: changeset,
      workspace_id: workspace_id,
      environment_id: environment_id
    )
  end

  def update(conn, %{
        "id" => id,
        "agent" => agent_params,
        "workspace_id" => workspace_id,
        "environment_id" => environment_id
      }) do
    agent = Agents.get_agent!(id)

    case Agents.update_agent(agent, agent_params) do
      {:ok, agent} ->
        conn
        |> put_flash(:info, "Agent updated successfully.")
        |> redirect(
          to:
            Routes.workspace_environment_agent_path(
              conn,
              :show,
              workspace_id,
              environment_id,
              agent
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          agent: agent,
          changeset: changeset,
          workspace_id: workspace_id,
          environment_id: environment_id
        )
    end
  end

  def delete(conn, %{
        "id" => id,
        "workspace_id" => workspace_id,
        "environment_id" => environment_id
      }) do
    agent = Agents.get_agent!(id)
    {:ok, _agent} = Agents.delete_agent(agent)

    conn
    |> put_flash(:info, "Agent deleted successfully.")
    |> redirect(
      to: Routes.workspace_environment_agent_path(conn, :index, workspace_id, environment_id)
    )
  end
end
