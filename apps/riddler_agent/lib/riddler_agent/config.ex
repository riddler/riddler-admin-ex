defmodule RiddlerAgent.Config do
  use GenServer

  require Logger

  defstruct [:api_key, :api_secret, :base_url, :workspace_id]

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
  Returns the currently configured base_url
  """
  @spec base_url() :: String.t()
  def base_url(), do: GenServer.call(__MODULE__, {:base_url, []})

  @doc """
  Returns the currently configured workspace_id
  """
  @spec workspace_id() :: String.t()
  def workspace_id(), do: GenServer.call(__MODULE__, {:workspace_id, []})

  # === GenServer Server Functions ===---------------------------------------

  @impl GenServer
  def init(%{api_key: api_key, api_secret: api_secret, base_url: base_url} \\ []) do
    Logger.info("Starting #{__MODULE__}")

    config = %__MODULE__{api_key: api_key, api_secret: api_secret, base_url: base_url}

    updated_config = request_remote_config(config)

    {:ok, updated_config}
  end

  @impl GenServer
  def handle_call({:api_key, _opts}, _from, %__MODULE__{api_key: api_key} = state) do
    {:reply, api_key, state}
  end

  @impl GenServer
  def handle_call({:base_url, _opts}, _from, %__MODULE__{base_url: base_url} = state) do
    {:reply, base_url, state}
  end

  @impl GenServer
  def handle_call({:workspace_id, _opts}, _from, %__MODULE__{workspace_id: workspace_id} = state) do
    {:reply, workspace_id, state}
  end

  def request_remote_config(%__MODULE__{base_url: _base_url, api_key: _api_key, api_secret: _api_secret} = module) do

    IO.inspect(module)
    module
  end
end
