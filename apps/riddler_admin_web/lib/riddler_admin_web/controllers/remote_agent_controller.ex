defmodule RiddlerAdminWeb.RemoteAgentController do
  use RiddlerAdminWeb, :controller

  def config(conn, params) do
    IO.inspect(conn)
    IO.inspect(params)

    json(conn, params)
  end
end
