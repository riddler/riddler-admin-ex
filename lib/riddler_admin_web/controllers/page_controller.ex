defmodule RiddlerAdminWeb.PageController do
  use RiddlerAdminWeb, :controller

  @spec home(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def home(conn, _params) do
    # Check if user is authenticated
    case conn.assigns[:current_scope] do
      nil ->
        # Not authenticated, show landing page
        render(conn, :home)

      %{user: _user} ->
        # Authenticated, redirect to dashboard which will handle workspace routing
        redirect(conn, to: ~p"/dashboard")
    end
  end
end
