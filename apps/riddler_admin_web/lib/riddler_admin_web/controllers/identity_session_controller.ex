defmodule RiddlerAdminWeb.IdentitySessionController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts
  alias RiddlerAdminWeb.IdentityAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"identity" => identity_params}) do
    %{"email" => email, "password" => password} = identity_params

    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      IdentityAuth.log_in_identity(conn, identity, identity_params)
    else
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> IdentityAuth.log_out_identity()
  end
end
