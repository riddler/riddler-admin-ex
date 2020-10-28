defmodule RiddlerAgent.Messaging.Consumers.DefinitionConsumer do
  def handle_message(body, %{attempts: attempts, id: id, timestamp: timestamp}) do
    IO.puts("""
    RIDDLER AGENT Received message###{id} #{timestamp} (attempts: #{attempts})

      #{body}
    """)
  end
end
