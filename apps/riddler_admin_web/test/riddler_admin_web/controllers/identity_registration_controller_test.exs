defmodule RiddlerAdminWeb.IdentityRegistrationControllerTest do
  use RiddlerAdminWeb.ConnCase, async: true

  import RiddlerAdmin.IdentitiesFixtures

  describe "GET /identities/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.identity_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_identity(identity_fixture())
        |> get(Routes.identity_registration_path(conn, :new))

      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /identities/register" do
    @tag :capture_log
    test "creates account and logs the identity in", %{conn: conn} do
      email = unique_identity_email()

      conn =
        post(conn, Routes.identity_registration_path(conn, :create), %{
          "identity" => %{"email" => email, "password" => valid_identity_password()}
        })

      assert get_session(conn, :identity_token)
      assert redirected_to(conn) =~ "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.identity_registration_path(conn, :create), %{
          "identity" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
