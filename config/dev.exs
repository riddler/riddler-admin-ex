use Mix.Config

config :riddler_admin,
  ecto_log_level: :debug,
  database_name: "riddler_admin_dev",
  database_host: "localhost",
  database_password: "postgres",
  database_pool_size: 10,
  database_port: 5432,
  database_username: "postgres"

config :riddler_admin_web,
  http_port: 2111,
  secret_key_base: "this really should be a long secret string but for development ...",
  signing_salt: "it's a secret to everybody",
  url_host: "localhost",
  url_port: 2111

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :riddler_admin_web, RiddlerAdminWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/riddler_admin_web/assets", __DIR__)
    ]
  ],
  # Watch static and templates for browser reloading.
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/riddler_admin_web/(live|views)/.*(ex)$",
      ~r"lib/riddler_admin_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :info

config :phoenix,
  # Initialize plugs at runtime for faster development compilation
  plug_init_mode: :runtime,
  # Set a higher stacktrace during development. Avoid configuring such
  # in production as building large stacktraces may be expensive.
  stacktrace_depth: 20

#-----------------------------------------------------------------------------
# RiddlerServer
#-----------------------------------------------------------------------------

# Configure your database
config :riddler_server,
  database_name: "riddler_server_dev",
  database_host: "localhost",
  database_password: "postgres",
  database_pool_size: 10,
  database_port: 5432,
  database_username: "postgres"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :riddler_server, RiddlerServerWeb.Endpoint,
  http: [port: 2112],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []
