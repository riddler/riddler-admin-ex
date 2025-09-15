defmodule RiddlerAdminWeb.PageController do
  use RiddlerAdminWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
