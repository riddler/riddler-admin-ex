defmodule RiddlerAgent.Remote do
  require Logger

  def config(client) do
    case Tesla.get(client, "/agent/config") do
      {:ok, %{status: 200, body: string_key_map}} ->
        remote_config =
          for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}

        {:ok, remote_config}

      {:ok, %{status: 401}} ->
        Logger.error("[AGT] Unauthorized error fetching remote config. Check API credentials.")
        {:error, :unauthorized}
    end
  end

  def client({base_url, api_key, api_secret}) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BasicAuth, username: api_key, password: api_secret}
    ]

    Tesla.client(middleware)
  end
end
