defmodule RiddlerAgent.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias RiddlerAdmin.Messaging

  alias RiddlerAgent.Messaging.Consumers.DefinitionConsumer

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: RiddlerAgent.Worker.start_link(arg)
      # {RiddlerAgent.Worker, arg}
    ]

    # This is bad
    # (not storing process here - Messaging and NSQPubSub need the attention)
    # help please!
    Messaging.subscribe("definitions", "riddler_agent", DefinitionConsumer)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RiddlerAgent.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
