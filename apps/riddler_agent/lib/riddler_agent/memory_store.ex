defmodule RiddlerAgent.MemoryStore do
  use GenServer

  require Logger

  defstruct [:definitions, :workspaces]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_consumer_opts \\ []) do
    Logger.info("Starting #{__MODULE__}")

    {:ok, %__MODULE__{definitions: %{}, workspaces: %{}}}
  end

  # === Messaging / GenServer Client Functions ===-----------------------------

  @doc """
  Update state from new definition
  """
  @spec add_definition(definition :: Map.t()) :: :ok | :error
  def add_definition(definition) when is_map(definition) do
    GenServer.call(__MODULE__, {:add_definition, definition})
  end

  @doc """
  Gets the most recently published definition for a workspace
  """
  @spec get_workspace(workspace_id :: String.t()) :: Map.t()
  def get_workspace(workspace_id) when is_binary(workspace_id) do
    GenServer.call(__MODULE__, {:get_workspace, workspace_id})
  end

  # === GenServer Server Functions ===---------------------------------------

  @impl GenServer
  def handle_call(
        {:add_definition, %{id: definition_id, workspace_id: workspace_id} = map},
        _from,
        %__MODULE__{definitions: definitions, workspaces: workspaces} = state
      ) do
    Logger.info("[AGT] Adding Definition #{definition_id} for Workspace #{workspace_id}")

    new_definitions =
      definitions
      |> Map.put(definition_id, map)

    new_workspaces =
      workspaces
      |> Map.put(workspace_id, map)

    {:reply, :ok, %__MODULE__{state | definitions: new_definitions, workspaces: new_workspaces}}
  end

  @impl GenServer
  def handle_call(
        {:get_workspace, workspace_id},
        _from,
        %__MODULE__{workspaces: workspaces} = state
      ) do
    Logger.debug("[AGT] Retrieving Definition for Workspace #{workspace_id}")

    {:reply, Map.get(workspaces, workspace_id), state}
  end
end
