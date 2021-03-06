defmodule RiddlerAdminWeb.RemoteAgentController do
  use RiddlerAdminWeb, :controller

  def config(%{assigns: %{current_agent: current_agent}} = conn, _params) do
    definition_yaml =
      current_agent.environment.definition && current_agent.environment.definition.yaml

    json(conn, %{
      agent_id: current_agent.id,
      agent_key: current_agent.key,
      environment_id: current_agent.environment.id,
      environment_key: current_agent.environment.key,
      workspace_id: current_agent.environment.workspace.id,
      workspace_key: current_agent.environment.workspace.key,
      definition: definition_yaml
    })
  end
end
