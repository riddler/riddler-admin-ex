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
  ecto_log_level: {:system, :atom, "ECTO_LOG_LEVEL", :info},
  ecto_repos: [RiddlerAdmin.Repo],
  database_name: {:system, :string, "DATABASE_NAME"},
  database_host: {:system, :string, "DATABASE_HOST"},
  database_password: {:system, :string, "DATABASE_PASSWORD"},
  database_pool_size: {:system, :integer, "DATABASE_POOL_SIZE", 10},
  database_port: {:system, :integer, "DATABASE_PORT", 5432},
  database_username: {:system, :string, "DATABASE_USERNAME"}

config :riddler_admin_web,
  ecto_repos: [RiddlerAdmin.Repo],
  generators: [context_app: :riddler_admin],
  http_port: {:system, :string, "HTTP_PORT", 6181},
  secret_key_base: {:system, :string, "SECRET_KEY_BASE"},
  signing_salt: {:system, :string, "SIGNING_SALT"},
  url_host: {:system, :string, "URL_HOST"},
  url_port: {:system, :integer, "URL_PORT"}

# Configure the DB Repo
config :riddler_admin, RiddlerAdmin.Repo,
  migration_primary_key: false,
  migration_foreign_key: [column: :id, type: :text],
  migration_timestamps: [type: :utc_datetime_usec],
  show_sensitive_data_on_connection_error: true

# Configures the endpoint
# Setting from the env are handled in RiddlerAdminWeb.Endpoint.init/2
config :riddler_admin_web, RiddlerAdminWeb.Endpoint,
  render_errors: [view: RiddlerAdminWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RiddlerAdmin.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
