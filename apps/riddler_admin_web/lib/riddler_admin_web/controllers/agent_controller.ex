defmodule RiddlerAdminWeb.AgentController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Agents
  alias RiddlerAdmin.Agents.Agent

  def index(conn, %{"account_id" => account_id, "workspace_id" => workspace_id}) do
    agents = Agents.list_agents()
    render(conn, "index.html", agents: agents, account_id: account_id, workspace_id: workspace_id)
  end

  def new(conn, %{"account_id" => account_id, "workspace_id" => workspace_id}) do
    changeset = Agents.change_agent(%Agent{})

    render(conn, "new.html",
      changeset: changeset,
      account_id: account_id,
      workspace_id: workspace_id
    )
  end

  def create(conn, %{
        "agent" => agent_params,
        "account_id" => account_id,
        "workspace_id" => workspace_id
      }) do
    case Agents.create_agent(agent_params, account_id) do
      {:ok, agent} ->
        conn
        |> put_flash(:info, "Agent created successfully.")
        |> redirect(
          to:
            Routes.account_workspace_agent_path(
              conn,
              :show,
              account_id,
              workspace_id,
              agent
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "account_id" => account_id, "workspace_id" => workspace_id}) do
    agent = Agents.get_agent!(id)
    render(conn, "show.html", agent: agent, account_id: account_id, workspace_id: workspace_id)
  end

  def edit(conn, %{"id" => id, "account_id" => account_id, "workspace_id" => workspace_id}) do
    agent = Agents.get_agent!(id)
    changeset = Agents.change_agent(agent)

    render(conn, "edit.html",
      agent: agent,
      changeset: changeset,
      account_id: account_id,
      workspace_id: workspace_id
    )
  end

  def update(conn, %{
        "id" => id,
        "agent" => agent_params,
        "account_id" => account_id,
        "workspace_id" => workspace_id
      }) do
    agent = Agents.get_agent!(id)

    case Agents.update_agent(agent, agent_params) do
      {:ok, agent} ->
        conn
        |> put_flash(:info, "Agent updated successfully.")
        |> redirect(
          to: Routes.account_workspace_agent_path(conn, :show, account_id, workspace_id, agent)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          agent: agent,
          changeset: changeset,
          account_id: account_id,
          workspace_id: workspace_id
        )
    end
  end

  def delete(conn, %{"id" => id, "account_id" => account_id, "workdspace_id" => workspace_id}) do
    agent = Agents.get_agent!(id)
    {:ok, _agent} = Agents.delete_agent(agent)

    conn
    |> put_flash(:info, "Agent deleted successfully.")
    |> redirect(to: Routes.account_workspace_agent_path(conn, :index, account_id, workspace_id))
  end
end
