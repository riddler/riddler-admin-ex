defmodule RiddlerAdmin.Infra.Messaging.NSQPubSub do
  use GenServer

  alias NSQ.Config, as: NSQConfig
  alias NSQ.Producer.Supervisor, as: ProducerSupervisor
  alias NSQ.Consumer.Supervisor, as: ConsumerSupervisor

  require Logger

  defstruct [:producer, :consumers]

  @default_topic "riddler-admin__command"
  @default_nsqd "127.0.0.1:4150"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(consumer_opts \\ []) do
    Logger.debug("Starting NSQ Producer")

    {:ok, producer} =
      ProducerSupervisor.start_link(default_topic(), %NSQConfig{
        nsqds: [nsqd()]
      })

    consumers =
      consumer_opts
      |> Enum.map(&start_consumer/1)

    {:ok, %__MODULE__{producer: producer, consumers: consumers}}
  end

  # === Messaging / GenServer Client Functions ===-----------------------------

  @doc """
  Publish a message to the specified topic
  """
  @spec publish(topic :: String.t(), message :: any()) :: :ok | :error
  def publish(topic, message) when is_binary(topic) do
    GenServer.call(__MODULE__, {:publish, {topic, message}})
  end

  @doc """
  Subscribe to a topic on a channel.
  """
  @spec subscribe(topic :: String.t(), channel :: String.t(), handler :: module()) ::
          :ok | :error
  def subscribe(topic, channel, handler)
      when is_binary(topic) and is_binary(channel) and is_atom(handler) do
    GenServer.call(__MODULE__, {:subscribe, {topic, channel, handler}})
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

  @impl GenServer
  def handle_call(
        {:subscribe, {_topic, _channel, _handler} = consumer_opts},
        _from,
        %__MODULE__{consumers: consumers} = state
      ) do
    consumer = start_consumer(consumer_opts)

    {:reply, :ok, %__MODULE__{state | consumers: [consumer | consumers]}}
  end

  # === Private Functions ===---------------------------------------

  defp default_topic(),
    do: Confex.get_env(:riddler_admin, :messaging_default_topic, @default_topic)

  defp nsqd(), do: Confex.get_env(:riddler_admin, :messaging_nsqd, @default_nsqd)

  defp start_consumer({topic, channel, handler}) do
    Logger.info("Starting NSQ Consumer for #{topic}:#{channel} using #{handler}")

    {:ok, consumer} =
      ConsumerSupervisor.start_link(topic, channel, %NSQConfig{
        nsqds: [nsqd()],
        message_handler: handler
      })

    consumer
  end
end
