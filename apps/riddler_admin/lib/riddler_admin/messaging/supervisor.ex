defmodule RiddlerAdmin.Messaging.Supervisor do
  @moduledoc """
  Supervisor to manage NSQ producers and consumers.
  """

  alias RiddlerAdmin.Infra.Messaging.NSQEchoHandler
  alias RiddlerAdmin.Infra.Messaging.NSQPubSub

  require Logger

  use Supervisor

  def init(:ok), do: Supervisor.init(children(), strategy: :one_for_one)

  def start_link(_args), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  # === Private Helpers

  defp nsq_enabled?(), do: Confex.get_env(:riddler_admin, :nsq_enabled?, true)

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
