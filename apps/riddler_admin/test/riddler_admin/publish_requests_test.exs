defmodule RiddlerAdmin.PublishRequestsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.PublishRequests

  describe "publish_requests" do
    alias RiddlerAdmin.PublishRequests.PublishRequest

    @valid_attrs %{approved_at: "2010-04-17T14:00:00.000000Z", message: "some message", published_at: "2010-04-17T14:00:00.000000Z", status: "some status", subject: "some subject"}
    @update_attrs %{approved_at: "2011-05-18T15:01:01.000000Z", message: "some updated message", published_at: "2011-05-18T15:01:01.000000Z", status: "some updated status", subject: "some updated subject"}
    @invalid_attrs %{approved_at: nil, message: nil, published_at: nil, status: nil, subject: nil}

    def publish_request_fixture(attrs \\ %{}) do
      {:ok, publish_request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PublishRequests.create_publish_request()

      publish_request
    end

    test "list_publish_requests/0 returns all publish_requests" do
      publish_request = publish_request_fixture()
      assert PublishRequests.list_publish_requests() == [publish_request]
    end

    test "get_publish_request!/1 returns the publish_request with given id" do
      publish_request = publish_request_fixture()
      assert PublishRequests.get_publish_request!(publish_request.id) == publish_request
    end

    test "create_publish_request/1 with valid data creates a publish_request" do
      assert {:ok, %PublishRequest{} = publish_request} = PublishRequests.create_publish_request(@valid_attrs)
      assert publish_request.approved_at == DateTime.from_naive!(~N[2010-04-17T14:00:00.000000Z], "Etc/UTC")
      assert publish_request.message == "some message"
      assert publish_request.published_at == DateTime.from_naive!(~N[2010-04-17T14:00:00.000000Z], "Etc/UTC")
      assert publish_request.status == "some status"
      assert publish_request.subject == "some subject"
    end

    test "create_publish_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PublishRequests.create_publish_request(@invalid_attrs)
    end

    test "update_publish_request/2 with valid data updates the publish_request" do
      publish_request = publish_request_fixture()
      assert {:ok, %PublishRequest{} = publish_request} = PublishRequests.update_publish_request(publish_request, @update_attrs)
      assert publish_request.approved_at == DateTime.from_naive!(~N[2011-05-18T15:01:01.000000Z], "Etc/UTC")
      assert publish_request.message == "some updated message"
      assert publish_request.published_at == DateTime.from_naive!(~N[2011-05-18T15:01:01.000000Z], "Etc/UTC")
      assert publish_request.status == "some updated status"
      assert publish_request.subject == "some updated subject"
    end

    test "update_publish_request/2 with invalid data returns error changeset" do
      publish_request = publish_request_fixture()
      assert {:error, %Ecto.Changeset{}} = PublishRequests.update_publish_request(publish_request, @invalid_attrs)
      assert publish_request == PublishRequests.get_publish_request!(publish_request.id)
    end

    test "delete_publish_request/1 deletes the publish_request" do
      publish_request = publish_request_fixture()
      assert {:ok, %PublishRequest{}} = PublishRequests.delete_publish_request(publish_request)
      assert_raise Ecto.NoResultsError, fn -> PublishRequests.get_publish_request!(publish_request.id) end
    end

    test "change_publish_request/1 returns a publish_request changeset" do
      publish_request = publish_request_fixture()
      assert %Ecto.Changeset{} = PublishRequests.change_publish_request(publish_request)
    end
  end
end
