defmodule Messaging.Consumer do
  @default_adapter :nsq

  defmacro __using__(opts) do
    use_adapter(adapter(), opts)
  end

  defp use_adapter(:nsq, opts) do
    quote bind_quoted: [opts: opts] do
      alias NSQ.Config, as: NSQConfig
      alias NSQ.Consumer.Supervisor, as: NSQConsumerSupervisor

      @opts opts
      @topic Keyword.get(opts, :topic)
      @group Keyword.get(opts, :group)

      @default_nsqd "127.0.0.1:4150"

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []}
        }
      end

      def start_link() do
        NSQConsumerSupervisor.start_link(@topic, @group, %NSQConfig{
          nsqds: [@default_nsqd],
          message_handler: __MODULE__
        })
      end
    end
  end

  defp adapter() do
    Confex.get_env(:messaging, :adapter, @default_adapter)
  end
end
