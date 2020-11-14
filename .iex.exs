alias RiddlerAdmin.{
  Accounts,
  Accounts.Account,
  Agents,
  Agents.Agent,
  Conditions,
  Conditions.Condition,
  Workspaces,
  Workspaces.Workspace
}

defmodule I do
  @doc "Clears the terminal. So fresh and so clean."
  def c(), do: IEx.Helpers.clear()
  @doc "Dummy, but not dumb data."
  def dd(k), do: dummy_data(k)
  @doc "Starts the observer."
  def o(), do: :observer.start()
  @doc "Recompiles."
  def r(), do: IEx.Helpers.recompile()
  @doc "Yank words. Not chains"
  def y(t), do: yank(t)
  def copy(t), do: yank(t)
  @doc "Give a key for a reward in your clipboard"
  def ydd(k), do: k |> dd() |> y()

  defp yank(text) do
    text = to_s(text)
    port = Port.open({:spawn, "pbcopy"}, [])
    Port.command(port, text)
    Port.close(port)
    IO.puts("yanked: #{String.slice(text, 0, 10)}...")
  end

  defp dummy_data(key), do: Map.get(pkvsdd(), key)
  defp pkvsdd(), do: persistent_key_value_store_of_dummy_data()

  defp persistent_key_value_store_of_dummy_data() do
    # Add your data here
    %{
      example: %{foo: :bar}
    }
  end

  defp to_s(text) do
    to_string(text)
  rescue
    _ -> inspect(text, limit: :infinity, pretty: true)
  end
end
