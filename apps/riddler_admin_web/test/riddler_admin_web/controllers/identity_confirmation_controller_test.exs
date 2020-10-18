defmodule RiddlerAdminWeb.IdentityConfirmationControllerTest do
  use RiddlerAdminWeb.ConnCase, async: true

  alias RiddlerAdmin.Accounts
  alias RiddlerAdmin.Repo
  import RiddlerAdmin.AccountsFixtures

  setup do
    %{identity: identity_fixture()}
  end

  describe "GET /identitys/confirm" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.identity_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /identitys/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_confirmation_path(conn, :create), %{
          "identity" => %{"email" => identity.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.IdentityToken, identity_id: identity.id).context == "confirm"
    end

    test "does not send confirmation token if account is confirmed", %{
      conn: conn,
      identity: identity
    } do
      Repo.update!(Accounts.Identity.confirm_changeset(identity))

      conn =
        post(conn, Routes.identity_confirmation_path(conn, :create), %{
          "identity" => %{"email" => identity.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Accounts.IdentityToken, identity_id: identity.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.identity_confirmation_path(conn, :create), %{
          "identity" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.IdentityToken) == []
    end
  end

  describe "GET /identitys/confirm/:token" do
    test "confirms the given token once", %{conn: conn, identity: identity} do
      token =
        extract_identity_token(fn url ->
          Accounts.deliver_identity_confirmation_instructions(identity, url)
        end)

      conn = get(conn, Routes.identity_confirmation_path(conn, :confirm, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Account confirmed successfully"
      assert Accounts.get_identity!(identity.id).confirmed_at
      refute get_session(conn, :identity_token)
      assert Repo.all(Accounts.IdentityToken) == []

      conn = get(conn, Routes.identity_confirmation_path(conn, :confirm, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Confirmation link is invalid or it has expired"
    end

    test "does not confirm email with invalid token", %{conn: conn, identity: identity} do
      conn = get(conn, Routes.identity_confirmation_path(conn, :confirm, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Confirmation link is invalid or it has expired"
      refute Accounts.get_identity!(identity.id).confirmed_at
    end
  end
end
