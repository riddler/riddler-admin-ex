# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :riddler_server,
  ecto_repos: [RiddlerServer.Repo]

# Configures the endpoint
config :riddler_server, RiddlerServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nn6Kq8NmuTzZmqGlOcrjOm9oRSMUzxWVjo0WJ0vSSdcWPq6CG0BGvr9LKHcXaRXO",
  render_errors: [view: RiddlerServerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: RiddlerServer.PubSub,
  live_view: [signing_salt: "uPYiTQtX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
