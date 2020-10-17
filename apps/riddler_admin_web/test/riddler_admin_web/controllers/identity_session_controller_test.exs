defmodule RiddlerAdminWeb.IdentitySessionControllerTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import RiddlerAdmin.AccountsFixtures

  setup do
    %{identity: identity_fixture()}
  end

  describe "GET /identities/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.identity_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "redirects if already logged in", %{conn: conn, identity: identity} do
      conn = conn |> log_in_identity(identity) |> get(Routes.identity_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /identities/log_in" do
    test "logs the identity in", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_session_path(conn, :create), %{
          "identity" => %{"email" => identity.email, "password" => valid_identity_password()}
        })

      assert get_session(conn, :identity_token)
      assert redirected_to(conn) =~ "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ identity.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the identity in with remember me", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_session_path(conn, :create), %{
          "identity" => %{
            "email" => identity.email,
            "password" => valid_identity_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["identity_remember_me"]
      assert redirected_to(conn) =~ "/"
    end

    test "emits error message with invalid credentials", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_session_path(conn, :create), %{
          "identity" => %{"email" => identity.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /identities/log_out" do
    test "logs the identity out", %{conn: conn, identity: identity} do
      conn =
        conn |> log_in_identity(identity) |> delete(Routes.identity_session_path(conn, :delete))

      assert redirected_to(conn) == "/"
      refute get_session(conn, :identity_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the identity is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.identity_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :identity_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
