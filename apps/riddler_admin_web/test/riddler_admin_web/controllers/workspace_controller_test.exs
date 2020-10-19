# defmodule RiddlerAdminWeb.WorkspaceControllerTest do
#   use RiddlerAdminWeb.ConnCase

#   alias RiddlerAdmin.Workspaces

#   # @create_attrs %{name: "some name"}
#   # @update_attrs %{name: "some updated name"}
#   # @invalid_attrs %{name: nil}

#   # def fixture(:workspace) do
#   #   {:ok, workspace} = Workspaces.create_workspace(@create_attrs)
#   #   workspace
#   # end

#   describe "when not logged in" do
#     test "index redirects", %{conn: conn} do
#       conn
#       |> get(Routes.workspace_path(conn, :index))
#       |> assert_login_redirect()
#     end

#     test "new redirects", %{conn: conn} do
#       conn
#       |> get(Routes.workspace_path(conn, :new))
#       |> assert_login_redirect()
#     end

#     test "create redirects", %{conn: conn} do
#       conn
#       |> post(Routes.workspace_path(conn, :create, %{}))
#       |> assert_login_redirect()
#     end

#     test "show redirects", %{conn: conn} do
#       conn
#       |> get(Routes.workspace_path(conn, :show, "anything"))
#       |> assert_login_redirect()
#     end

#     test "edit redirects", %{conn: conn} do
#       conn
#       |> get(Routes.workspace_path(conn, :edit, "anything"))
#       |> assert_login_redirect()
#     end

#     test "update redirects", %{conn: conn} do
#       conn
#       |> put(Routes.workspace_path(conn, :update, "anything", %{}))
#       |> assert_login_redirect()
#     end

#     test "delete redirects", %{conn: conn} do
#       conn
#       |> delete(Routes.workspace_path(conn, :delete, "anything"))
#       |> assert_login_redirect()
#     end
#   end

#   describe "index" do
#     setup :register_and_log_in_identity

#     test "lists all workspaces", %{conn: conn} do
#       conn = get(conn, Routes.workspace_path(conn, :index))
#       assert html_response(conn, 200) =~ "Listing Workspaces"
#     end
#   end

#   describe "new workspace" do
#     setup :register_and_log_in_identity

#     test "renders form", %{conn: conn} do
#       conn = get(conn, Routes.workspace_path(conn, :new))
#       assert html_response(conn, 200) =~ "New Workspace"
#     end
#   end

#   describe "create workspace" do
#     test "redirects to show when data is valid", %{conn: conn} do
#       setup :register_and_log_in_identity
#       conn = post(conn, Routes.workspace_path(conn, :create), workspace: @create_attrs)

#       assert %{id: id} = redirected_params(conn)
#       assert redirected_to(conn) == Routes.workspace_path(conn, :show, id)

#       conn = get(conn, Routes.workspace_path(conn, :show, id))
#       assert html_response(conn, 200) =~ "Show Workspace"
#     end

#     test "renders errors when data is invalid", %{conn: conn} do
#       setup :register_and_log_in_identity
#       conn = post(conn, Routes.workspace_path(conn, :create), workspace: @invalid_attrs)
#       assert html_response(conn, 200) =~ "New Workspace"
#     end
#   end

#   # describe "edit workspace" do
#   #   setup [:create_workspace]

#   #   test "renders form for editing chosen workspace", %{conn: conn, workspace: workspace} do
#   #     conn = get(conn, Routes.workspace_path(conn, :edit, workspace))
#   #     assert html_response(conn, 200) =~ "Edit Workspace"
#   #   end
#   # end

#   # describe "update workspace" do
#   #   setup [:create_workspace]

#   #   test "redirects when data is valid", %{conn: conn, workspace: workspace} do
#   #     conn = put(conn, Routes.workspace_path(conn, :update, workspace), workspace: @update_attrs)
#   #     assert redirected_to(conn) == Routes.workspace_path(conn, :show, workspace)

#   #     conn = get(conn, Routes.workspace_path(conn, :show, workspace))
#   #     assert html_response(conn, 200) =~ "some updated name"
#   #   end

#   #   test "renders errors when data is invalid", %{conn: conn, workspace: workspace} do
#   #     conn = put(conn, Routes.workspace_path(conn, :update, workspace), workspace: @invalid_attrs)
#   #     assert html_response(conn, 200) =~ "Edit Workspace"
#   #   end
#   # end

#   # describe "delete workspace" do
#   #   setup [:create_workspace]

#   #   test "deletes chosen workspace", %{conn: conn, workspace: workspace} do
#   #     conn = delete(conn, Routes.workspace_path(conn, :delete, workspace))
#   #     assert redirected_to(conn) == Routes.workspace_path(conn, :index)
#   #     assert_error_sent 404, fn ->
#   #       get(conn, Routes.workspace_path(conn, :show, workspace))
#   #     end
#   #   end
#   # end

#   # defp create_workspace(_) do
#   #   workspace = fixture(:workspace)
#   #   %{workspace: workspace}
#   # end
# end
