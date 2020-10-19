defmodule RiddlerAdminWeb.IdentityResetPasswordController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Identities

  plug :get_identity_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"identity" => %{"email" => email}}) do
    if identity = Identities.get_identity_by_email(email) do
      Identities.deliver_identity_reset_password_instructions(
        identity,
        &Routes.identity_reset_password_url(conn, :edit, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html",
      changeset: Identities.change_identity_password(conn.assigns.identity)
    )
  end

  # Do not log in the identity after reset password to avoid a
  # leaked token giving the identity access to the account.
  def update(conn, %{"identity" => identity_params}) do
    case Identities.reset_identity_password(conn.assigns.identity, identity_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.identity_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_identity_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if identity = Identities.get_identity_by_reset_password_token(token) do
      conn |> assign(:identity, identity) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
