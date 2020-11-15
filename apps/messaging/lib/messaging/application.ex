defmodule Messaging.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  alias Messaging.Infra.NSQEchoHandler
  alias Messaging.Infra.NSQPubSub

  def start(_type, _args) do
    Supervisor.start_link(children(), strategy: :one_for_one, name: Messaging.Supervisor)
  end

  # === Private Helpers

  defp nsq_enabled?(), do: Confex.get_env(:messaging, :nsq_enabled?, true)

  defp children() do
    if nsq_enabled?() do
      [
        {NSQPubSub,
         [
           {"conditions__command", "processor", NSQEchoHandler}
         ]}
      ]
    else
      Logger.info("Not starting #{NSQPubSub} due to NSQ not being enabled.")

      []
    end
  end
end
