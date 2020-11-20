defmodule Messaging.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Messaging.Infra.NSQ.Server, as: NSQServer

  require Logger

  @default_adapter :nsq

  def start(_type, _args) do
    Supervisor.start_link(children(), strategy: :one_for_one, name: Messaging.Supervisor)
  end

  # === Private Helpers

  defp children() do
    case adapter() do
      :nsq ->
        [NSQServer]
      other ->
        Logger.info("Not starting #{NSQServer}. Messaging adapter: #{other}")
        []
    end
  end

  defp adapter() do
    Confex.get_env(:messaging, :adapter, @default_adapter)
  end
end
