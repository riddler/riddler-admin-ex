# defmodule RiddlerAgent.Remote do
#   use Tesla

#   alias RiddlerAgent.Config

#   plug Tesla.Middleware.BaseUrl, Config.base_url()
#   plug Tesla.Middleware.BasicAuth, username: Config.api_key(), password: Config.api_secret()
#   plug Tesla.Middleware.JSON

#   def config({_base_url, _api_key, _api_secret}) do
#     {:ok, %{body: string_key_map}} = get("/agent/config")

#     for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
#   end
# end

defmodule RiddlerAgent.Remote do
  def config(client) do
    {:ok, %{body: string_key_map}} = Tesla.get(client, "/agent/config")

    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
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
