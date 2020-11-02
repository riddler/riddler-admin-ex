defmodule RiddlerAgent.Remote do
  use Tesla

  alias RiddlerAgent.Config

  plug Tesla.Middleware.BaseUrl, Config.base_url()
  # plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON

  # def new(username, password, opts \\ %{}) do
  #   Tesla.client [
  #     {Tesla.Middleware.BasicAuth, Map.merge(%{username: username, password: password}, opts)}
  #   ]
  # end
  # def user_repos(login) do
  #   get("/users/" <> login <> "/repos")
  # end

  def test() do
    get("/agent/config")
  end
end
