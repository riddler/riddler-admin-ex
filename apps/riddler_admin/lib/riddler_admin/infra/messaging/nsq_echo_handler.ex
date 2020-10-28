defmodule RiddlerAdmin.Infra.Messaging.NSQEchoHandler do
  def handle_message(body, %{attempts: attempts, id: id, timestamp: timestamp}) do
    IO.puts("""
    Received message###{id} #{timestamp} (attempts: #{attempts})

      #{body}
    """)
  end
end
