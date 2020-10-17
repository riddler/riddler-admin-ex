defmodule RiddlerAdminWeb.IdentityRegistrationController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Accounts
  alias RiddlerAdmin.Accounts.Identity
  alias RiddlerAdminWeb.IdentityAuth

  def new(conn, _params) do
    changeset = Accounts.change_identity_registration(%Identity{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"identity" => identity_params}) do
    case Accounts.register_identity(identity_params) do
      {:ok, identity} ->
        {:ok, _} =
          Accounts.deliver_identity_confirmation_instructions(
            identity,
            &Routes.identity_confirmation_url(conn, :confirm, &1)
          )

        conn
        |> put_flash(:info, "Identity created successfully.")
        |> IdentityAuth.log_in_identity(identity)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
