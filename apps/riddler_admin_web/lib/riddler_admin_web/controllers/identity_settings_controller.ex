defmodule RiddlerAdminWeb.IdentitySettingsController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts
  alias RiddlerAdminWeb.IdentityAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update_email(conn, %{"current_password" => password, "identity" => identity_params}) do
    identity = conn.assigns.current_identity

    case Accounts.apply_identity_email(identity, password, identity_params) do
      {:ok, applied_identity} ->
        Accounts.deliver_update_email_instructions(
          applied_identity,
          identity.email,
          &Routes.identity_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.identity_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_identity_email(conn.assigns.current_identity, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.identity_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.identity_settings_path(conn, :edit))
    end
  end

  def update_password(conn, %{"current_password" => password, "identity" => identity_params}) do
    identity = conn.assigns.current_identity

    case Accounts.update_identity_password(identity, password, identity_params) do
      {:ok, identity} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:identity_return_to, Routes.identity_settings_path(conn, :edit))
        |> IdentityAuth.log_in_identity(identity)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    identity = conn.assigns.current_identity

    conn
    |> assign(:email_changeset, Accounts.change_identity_email(identity))
    |> assign(:password_changeset, Accounts.change_identity_password(identity))
  end
end
