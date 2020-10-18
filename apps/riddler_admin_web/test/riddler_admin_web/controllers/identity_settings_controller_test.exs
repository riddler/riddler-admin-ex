defmodule RiddlerAdminWeb.IdentitySettingsControllerTest do
  use RiddlerAdminWeb.ConnCase, async: true

  alias RiddlerAdmin.Accounts
  import RiddlerAdmin.AccountsFixtures

  setup :register_and_log_in_identity

  describe "GET /identities/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.identity_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if identity is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.identity_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.identity_session_path(conn, :new)
    end
  end

  describe "PUT /identities/settings/update_password" do
    test "updates the identity password and resets tokens", %{conn: conn, identity: identity} do
      new_password_conn =
        put(conn, Routes.identity_settings_path(conn, :update_password), %{
          "current_password" => valid_identity_password(),
          "identity" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.identity_settings_path(conn, :edit)
      assert get_session(new_password_conn, :identity_token) != get_session(conn, :identity_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Accounts.get_identity_by_email_and_password(identity.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.identity_settings_path(conn, :update_password), %{
          "current_password" => "invalid",
          "identity" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :identity_token) == get_session(conn, :identity_token)
    end
  end

  describe "PUT /identities/settings/update_email" do
    @tag :capture_log
    test "updates the identity email", %{conn: conn, identity: identity} do
      conn =
        put(conn, Routes.identity_settings_path(conn, :update_email), %{
          "current_password" => valid_identity_password(),
          "identity" => %{"email" => unique_identity_email()}
        })

      assert redirected_to(conn) == Routes.identity_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Accounts.get_identity_by_email(identity.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.identity_settings_path(conn, :update_email), %{
          "current_password" => "invalid",
          "identity" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /identities/settings/confirm_email/:token" do
    setup %{identity: identity} do
      email = unique_identity_email()

      token =
        extract_identity_token(fn url ->
          Accounts.deliver_update_email_instructions(
            %{identity | email: email},
            identity.email,
            url
          )
        end)

      %{token: token, email: email}
    end

    test "updates the identity email once", %{
      conn: conn,
      identity: identity,
      token: token,
      email: email
    } do
      conn = get(conn, Routes.identity_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.identity_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Accounts.get_identity_by_email(identity.email)
      assert Accounts.get_identity_by_email(email)

      conn = get(conn, Routes.identity_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.identity_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, identity: identity} do
      conn = get(conn, Routes.identity_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.identity_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Accounts.get_identity_by_email(identity.email)
    end

    test "redirects if identity is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.identity_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.identity_session_path(conn, :new)
    end
  end
end
