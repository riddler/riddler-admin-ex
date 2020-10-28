defmodule RiddlerAdminWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :riddler_admin_web

  socket "/socket", RiddlerAdminWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [
      connect_info: [
        session: [
          store: :cookie,
          key: "_riddler_admin_web_key",
          signing_salt: Confex.get_env(:riddler_admin_web, :signing_salt)
        ]
      ]
    ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :riddler_admin_web,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :riddler_admin_web
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_riddler_admin_web_key",
    signing_salt: Confex.get_env(:riddler_admin_web, :signing_salt)

  plug RiddlerAdminWeb.Router

  def init(_type, config) do
    config =
      config
      |> Keyword.put(:http,
        port: Confex.get_env(:riddler_admin_web, :http_port),
        transport_options: [socket_opts: [:inet6]]
      )
      |> Keyword.put(:secret_key_base, Confex.get_env(:riddler_admin_web, :secret_key_base))
      |> Keyword.put(:live_view, signing_salt: Confex.get_env(:riddler_admin_web, :signing_salt))
      |> Keyword.put(:url,
        host: Confex.get_env(:riddler_admin_web, :url_host),
        port: Confex.get_env(:riddler_admin_web, :url_port)
      )

    {:ok, config}
  end
end
