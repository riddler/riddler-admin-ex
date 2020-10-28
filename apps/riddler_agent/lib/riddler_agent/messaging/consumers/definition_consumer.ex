defmodule RiddlerAgent.Messaging.Consumers.DefinitionConsumer do
  def handle_message(body, %{attempts: attempts, id: id, timestamp: timestamp}) do
    %{"yaml" => yaml} =
      map =
      body
      |> Jason.decode!()

    IO.puts("""
    RIDDLER AGENT Received message###{id} #{timestamp} (attempts: #{attempts})

    #{yaml}
    """)
  end
end
