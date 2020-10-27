defmodule RiddlerAdminWeb.AgentControllerTest do
  use RiddlerAdminWeb.ConnCase

  alias RiddlerAdmin.Agents

  @create_attrs %{api_key: "some api_key", api_secret: "some api_secret", name: "some name"}
  @update_attrs %{api_key: "some updated api_key", api_secret: "some updated api_secret", name: "some updated name"}
  @invalid_attrs %{api_key: nil, api_secret: nil, name: nil}

  def fixture(:agent) do
    {:ok, agent} = Agents.create_agent(@create_attrs)
    agent
  end

  describe "index" do
    test "lists all agents", %{conn: conn} do
      conn = get(conn, Routes.agent_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Agents"
    end
  end

  describe "new agent" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.agent_path(conn, :new))
      assert html_response(conn, 200) =~ "New Agent"
    end
  end

  describe "create agent" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.agent_path(conn, :create), agent: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.agent_path(conn, :show, id)

      conn = get(conn, Routes.agent_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Agent"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.agent_path(conn, :create), agent: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Agent"
    end
  end

  describe "edit agent" do
    setup [:create_agent]

    test "renders form for editing chosen agent", %{conn: conn, agent: agent} do
      conn = get(conn, Routes.agent_path(conn, :edit, agent))
      assert html_response(conn, 200) =~ "Edit Agent"
    end
  end

  describe "update agent" do
    setup [:create_agent]

    test "redirects when data is valid", %{conn: conn, agent: agent} do
      conn = put(conn, Routes.agent_path(conn, :update, agent), agent: @update_attrs)
      assert redirected_to(conn) == Routes.agent_path(conn, :show, agent)

      conn = get(conn, Routes.agent_path(conn, :show, agent))
      assert html_response(conn, 200) =~ "some updated api_key"
    end

    test "renders errors when data is invalid", %{conn: conn, agent: agent} do
      conn = put(conn, Routes.agent_path(conn, :update, agent), agent: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Agent"
    end
  end

  describe "delete agent" do
    setup [:create_agent]

    test "deletes chosen agent", %{conn: conn, agent: agent} do
      conn = delete(conn, Routes.agent_path(conn, :delete, agent))
      assert redirected_to(conn) == Routes.agent_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.agent_path(conn, :show, agent))
      end
    end
  end

  defp create_agent(_) do
    agent = fixture(:agent)
    %{agent: agent}
  end
end
