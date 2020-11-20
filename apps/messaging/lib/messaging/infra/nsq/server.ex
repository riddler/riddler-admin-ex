defmodule Messaging.Infra.NSQ.Server do
  use GenServer

  alias NSQ.Config, as: NSQConfig
  alias NSQ.Producer.Supervisor, as: ProducerSupervisor

  require Logger

  defstruct [:producer]

  @default_topic "__default_topic__"
  @default_nsqd "127.0.0.1:4150"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts \\ []) do
    Logger.info("Starting NSQ Producer")

    {:ok, producer} =
      ProducerSupervisor.start_link(default_topic(), %NSQConfig{
        nsqds: [nsqd()]
      })

    {:ok, %__MODULE__{producer: producer}}
  end

  # === Messaging / GenServer Client Functions ===-----------------------------

  @doc """
  Publish a message to the specified topic
  """
  @spec publish(topic :: String.t(), message :: any()) :: :ok | :error
  def publish(topic, message) when is_binary(topic) do
    GenServer.call(__MODULE__, {:publish, {topic, message}})
  end

  # === GenServer Server Functions ===---------------------------------------

  @impl GenServer
  def handle_call(
        {:publish, {topic, message}},
        _from,
        %__MODULE__{producer: producer} = state
      ) do
    NSQ.Producer.pub(producer, topic, message)

    {:reply, :ok, state}
  end

  # === Private Functions ===---------------------------------------

  defp default_topic(),
    do: Confex.get_env(:riddler_admin, :messaging_default_topic, @default_topic)

  defp nsqd(), do: Confex.get_env(:riddler_admin, :messaging_nsqd, @default_nsqd)
end
