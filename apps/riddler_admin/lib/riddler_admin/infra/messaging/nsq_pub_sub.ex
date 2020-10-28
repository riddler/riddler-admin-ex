defmodule RiddlerAdmin.Infra.Messaging.NSQPubSub do
  use GenServer

  alias NSQ.Config, as: NSQConfig
  alias NSQ.Producer.Supervisor, as: ProducerSupervisor
  alias NSQ.Consumer.Supervisor, as: ConsumerSupervisor

  require Logger

  defstruct [:producer, :consumers]

  @default_topic_name "riddler-admin__command"
  @default_nsqd "127.0.0.1:4150"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(consumer_opts \\ []) do
    Logger.debug("Starting NSQ Producer")

    {:ok, producer} =
      ProducerSupervisor.start_link(default_topic_name(), %NSQConfig{
        nsqds: [nsqd()]
      })

    consumers =
      consumer_opts
      |> Enum.map(fn {topic, channel, handler} ->
        Logger.debug("Starting NSQ Consumer for #{topic}:#{channel} using #{handler}")

        {:ok, consumer} =
          ConsumerSupervisor.start_link(topic, channel, %NSQConfig{
            nsqds: [nsqd()],
            message_handler: handler
          })

        consumer
      end)

    {:ok, %__MODULE__{producer: producer, consumers: consumers}}
  end

  # === Messaging / GenServer Client Functions ===-----------------------------

  @doc """
  Publish a message to the specified topic
  """
  @spec publish(topic_name :: String.t(), message :: any()) :: :ok | :error
  def publish(topic_name, message) when is_binary(topic_name) do
    GenServer.call(__MODULE__, {:publish, {topic_name, message}})
  end

  # === GenServer Server Functions ===---------------------------------------

  @impl GenServer
  def handle_call(
        {:publish, {topic_name, message}},
        _from,
        %__MODULE__{producer: producer} = state
      ) do
    NSQ.Producer.pub(producer, topic_name, message)

    {:reply, :ok, state}
  end

  # === Private Functions ===---------------------------------------

  defp default_topic_name(),
    do: Confex.get_env(:riddler_admin, :messaging_default_topic_name, @default_topic_name)

  defp nsqd(), do: Confex.get_env(:riddler_admin, :messaging_nsqd, @default_nsqd)
end
