defmodule RiddlerAdminWeb.IdentityConfirmationController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Identities

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"identity" => %{"email" => email}}) do
    if identity = Identities.get_identity_by_email(email) do
      Identities.deliver_identity_confirmation_instructions(
        identity,
        &Routes.identity_confirmation_url(conn, :confirm, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  # Do not log in the identity after confirmation to avoid a
  # leaked token giving the identity access to the account.
  def confirm(conn, %{"token" => token}) do
    case Identities.confirm_identity(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        conn
        |> put_flash(:error, "Confirmation link is invalid or it has expired.")
        |> redirect(to: "/")
    end
  end
end
