defmodule RiddlerServer.MemoryStore do
  use GenServer

  require Logger

  defstruct [:definitions, :workspaces, :environments]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_consumer_opts \\ []) do
    Logger.info("Starting #{__MODULE__}")

    {:ok, %__MODULE__{definitions: %{}, workspaces: %{}, environments: %{}}}
  end

  # === Messaging / GenServer Client Functions ===-----------------------------

  @doc """
  Update state from new definition
  """
  @spec add_definition(definition :: Map.t(), environment_id :: String.t()) :: :ok | :error
  def add_definition(definition, environment_id)
      when is_map(definition) and is_binary(environment_id) do
    GenServer.call(__MODULE__, {:add_definition, {definition, environment_id}})
  end

  @doc """
  Gets the most recently published definition for a workspace
  """
  @spec get_workspace(workspace_id :: String.t()) :: Map.t()
  def get_workspace(workspace_id) when is_binary(workspace_id) do
    GenServer.call(__MODULE__, {:get_workspace, workspace_id})
  end

  @doc """
  Gets the current definition for an environment
  """
  @spec get_environment(environment_id :: String.t()) :: Map.t()
  def get_environment(environment_id) when is_binary(environment_id) do
    GenServer.call(__MODULE__, {:get_environment, environment_id})
  end

  # === GenServer Server Functions ===---------------------------------------

  @impl GenServer
  def handle_call(
        {:add_definition,
         {%{id: definition_id, workspace_id: workspace_id} = map, environment_id}},
        _from,
        %__MODULE__{definitions: definitions, workspaces: workspaces, environments: environments} =
          state
      ) do
    Logger.info(
      "[RSRV] Adding Definition #{definition_id} for Workspace #{workspace_id} in #{
        environment_id
      }"
    )

    new_definitions =
      definitions
      |> Map.put(definition_id, map)

    new_workspaces =
      workspaces
      |> Map.put(workspace_id, map)

    new_environments =
      environments
      |> Map.put(environment_id, map)

    {:reply, :ok,
     %__MODULE__{
       state
       | definitions: new_definitions,
         workspaces: new_workspaces,
         environments: new_environments
     }}
  end

  @impl GenServer
  def handle_call(
        {:get_workspace, workspace_id},
        _from,
        %__MODULE__{workspaces: workspaces} = state
      ) do
    Logger.debug("[RSRV] Retrieving Definition for Workspace #{workspace_id}")

    {:reply, Map.get(workspaces, workspace_id), state}
  end

  @impl GenServer
  def handle_call(
        {:get_environment, environment_id},
        _from,
        %__MODULE__{environments: environments} = state
      ) do
    Logger.debug("[RSRV] Retrieving Definition for Environment #{environment_id}")

    {:reply, Map.get(environments, environment_id), state}
  end
end
