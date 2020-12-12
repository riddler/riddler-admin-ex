defmodule RiddlerServer.Config do
  use GenServer

  require Logger

  alias RiddlerServer.Remote

  @initial_delay_ms 1000

  defstruct [
    :api_key,
    :api_secret,
    :base_url,
    :agent_id,
    :agent_key,
    :workspace_id,
    :workspace_key,
    :environment_id,
    :environment_key
  ]

  # === Messaging / GenServer Client Functions ===-----------------------------

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Returns the currently configured api_key
  """
  @spec api_key() :: String.t()
  def api_key(), do: GenServer.call(__MODULE__, {:api_key, []})

  @doc """
  Returns the currently configured api_secret
  """
  @spec api_secret() :: String.t()
  def api_secret(), do: GenServer.call(__MODULE__, {:api_secret, []})

  @doc """
  Returns the currently configured base_url
  """
  @spec base_url() :: String.t()
  def base_url(), do: GenServer.call(__MODULE__, {:base_url, []})

  @doc """
  Returns the currently configured workspace_id
  """
  @spec environment_id() :: String.t()
  def environment_id(), do: GenServer.call(__MODULE__, {:environment_id, []})

  @doc """
  Returns the currently configured workspace_id
  """
  @spec workspace_id() :: String.t()
  def workspace_id(), do: GenServer.call(__MODULE__, {:workspace_id, []})

  # === GenServer Server Functions ===---------------------------------------

  @impl GenServer
  def init(%{api_key: api_key, api_secret: api_secret, base_url: base_url} \\ []) do
    Logger.info("[AGT] Starting #{__MODULE__}")

    Process.send_after(self(), :request_remote_config, @initial_delay_ms)

    {:ok, %__MODULE__{api_key: api_key, api_secret: api_secret, base_url: base_url}}
  end

  @impl GenServer
  def handle_call({:api_key, _opts}, _from, %__MODULE__{api_key: api_key} = state) do
    {:reply, api_key, state}
  end

  @impl GenServer
  def handle_call({:api_secret, _opts}, _from, %__MODULE__{api_secret: api_secret} = state) do
    {:reply, api_secret, state}
  end

  @impl GenServer
  def handle_call({:base_url, _opts}, _from, %__MODULE__{base_url: base_url} = state) do
    {:reply, base_url, state}
  end

  @impl GenServer
  def handle_call(
        {:environment_id, _opts},
        _from,
        %__MODULE__{environment_id: environment_id} = state
      ) do
    {:reply, environment_id, state}
  end

  @impl GenServer
  def handle_call({:workspace_id, _opts}, _from, %__MODULE__{workspace_id: workspace_id} = state) do
    {:reply, workspace_id, state}
  end

  @impl GenServer
  def handle_info(
        :request_remote_config,
        %__MODULE__{base_url: base_url, api_key: api_key, api_secret: api_secret} = state
      ) do
    {base_url, api_key, api_secret}
    |> request_remote_config()
    |> case do
      {:ok, remote_config} ->
        RiddlerServer.store_definition(remote_config.definition, remote_config.environment_id)

        {:noreply,
         %{
           state
           | agent_id: remote_config.agent_id,
             agent_key: remote_config.agent_key,
             workspace_id: remote_config.workspace_id,
             workspace_key: remote_config.workspace_key,
             environment_id: remote_config.environment_id,
             environment_key: remote_config.environment_key
         }}

      {:error, _} ->
        raise "Error fetching remote config"
    end
  end

  defp request_remote_config(remote_connection_opts) do
    Logger.info("[AGT] Requesting remote configuration")

    Remote.client(remote_connection_opts)
    |> Remote.config()
  end
end
