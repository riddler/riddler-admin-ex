defmodule RiddlerServerWeb.ContentController do
  use RiddlerServerWeb, :controller

  def show(conn, %{"key" => content_block_key} = params) do
    generated_content = RiddlerServer.generate_content(content_block_key, params)
    json(conn, generated_content)
  end
end
