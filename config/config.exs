# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :riddler_admin,
  ecto_repos: [RiddlerAdmin.Repo]

config :riddler_admin_web,
  ecto_repos: [RiddlerAdmin.Repo],
  generators: [context_app: :riddler_admin]

# Configure the DB Repo
config :riddler_admin, RiddlerAdmin.Repo,
  migration_primary_key: false,
  migration_foreign_key: [column: :id, type: :text],
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :riddler_admin_web, RiddlerAdminWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "j9txzGk+AebZ4XrvN1DdTy6zq4pBkG/b8OK7+PALFzx3UkVpHvi0KrwEdugu3iYU",
  render_errors: [view: RiddlerAdminWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RiddlerAdmin.PubSub,
  live_view: [signing_salt: "pAIafCPw"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
