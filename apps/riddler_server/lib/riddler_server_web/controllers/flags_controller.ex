defmodule RiddlerServerWeb.FlagController do
  use RiddlerServerWeb, :controller

  def index(conn, params) do
    json(conn, RiddlerServer.all_flags(params))
  end

  def show(conn, %{"key" => flag_key} = params) do
    json(conn, RiddlerServer.treatment(flag_key, params))
  end
end
