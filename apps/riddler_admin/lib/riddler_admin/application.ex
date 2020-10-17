defmodule RiddlerAdmin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      RiddlerAdmin.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: RiddlerAdmin.PubSub}
      # Start a worker by calling: RiddlerAdmin.Worker.start_link(arg)
      # {RiddlerAdmin.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RiddlerAdmin.Supervisor)
  end
end
