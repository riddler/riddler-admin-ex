defmodule RiddlerAdminWeb.PublishRequestControllerTest do
  use RiddlerAdminWeb.ConnCase

  alias RiddlerAdmin.PublishRequests

  @create_attrs %{approved_at: "2010-04-17T14:00:00.000000Z", message: "some message", published_at: "2010-04-17T14:00:00.000000Z", status: "some status", subject: "some subject"}
  @update_attrs %{approved_at: "2011-05-18T15:01:01.000000Z", message: "some updated message", published_at: "2011-05-18T15:01:01.000000Z", status: "some updated status", subject: "some updated subject"}
  @invalid_attrs %{approved_at: nil, message: nil, published_at: nil, status: nil, subject: nil}

  def fixture(:publish_request) do
    {:ok, publish_request} = PublishRequests.create_publish_request(@create_attrs)
    publish_request
  end

  describe "index" do
    test "lists all publish_requests", %{conn: conn} do
      conn = get(conn, Routes.publish_request_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Publish requests"
    end
  end

  describe "new publish_request" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.publish_request_path(conn, :new))
      assert html_response(conn, 200) =~ "New Publish request"
    end
  end

  describe "create publish_request" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.publish_request_path(conn, :create), publish_request: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.publish_request_path(conn, :show, id)

      conn = get(conn, Routes.publish_request_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Publish request"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.publish_request_path(conn, :create), publish_request: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Publish request"
    end
  end

  describe "edit publish_request" do
    setup [:create_publish_request]

    test "renders form for editing chosen publish_request", %{conn: conn, publish_request: publish_request} do
      conn = get(conn, Routes.publish_request_path(conn, :edit, publish_request))
      assert html_response(conn, 200) =~ "Edit Publish request"
    end
  end

  describe "update publish_request" do
    setup [:create_publish_request]

    test "redirects when data is valid", %{conn: conn, publish_request: publish_request} do
      conn = put(conn, Routes.publish_request_path(conn, :update, publish_request), publish_request: @update_attrs)
      assert redirected_to(conn) == Routes.publish_request_path(conn, :show, publish_request)

      conn = get(conn, Routes.publish_request_path(conn, :show, publish_request))
      assert html_response(conn, 200) =~ "some updated message"
    end

    test "renders errors when data is invalid", %{conn: conn, publish_request: publish_request} do
      conn = put(conn, Routes.publish_request_path(conn, :update, publish_request), publish_request: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Publish request"
    end
  end

  describe "delete publish_request" do
    setup [:create_publish_request]

    test "deletes chosen publish_request", %{conn: conn, publish_request: publish_request} do
      conn = delete(conn, Routes.publish_request_path(conn, :delete, publish_request))
      assert redirected_to(conn) == Routes.publish_request_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.publish_request_path(conn, :show, publish_request))
      end
    end
  end

  defp create_publish_request(_) do
    publish_request = fixture(:publish_request)
    %{publish_request: publish_request}
  end
end
