defmodule RiddlerAdmin.WorkspacesTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Workspaces

  describe "workspaces" do
    alias RiddlerAdmin.Accounts
    alias RiddlerAdmin.Identities
    alias RiddlerAdmin.Workspaces.Workspace

    @identity_attrs %{email: "foo@bar.com", password: "Zaq1Xsw2Cde3"}
    @account_attrs %{name: "some name"}

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def workspace_fixture(attrs \\ %{}) do
      {:ok, identity} =
        @identity_attrs
        |> Identities.register_identity()

      {:ok, account} =
        @account_attrs
        |> Accounts.create_account_with_owner(identity.id)

      {:ok, workspace} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workspaces.create_workspace_with_account_and_owner(account.id, identity.id)

      workspace
    end

    test "list_workspaces/0 returns all workspaces" do
      %{name: name} = workspace_fixture()
      assert [%{name: ^name}] = Workspaces.list_workspaces()
    end

    test "get_workspace!/1 returns the workspace with given id" do
      %{id: id, name: name} = workspace_fixture()
      assert %{id: ^id, name: ^name} = Workspaces.get_workspace!(id)
    end

    test "create_workspace/1 with valid data creates a workspace" do
      {:ok, identity} =
        @identity_attrs
        |> Identities.register_identity()

      {:ok, account} =
        @account_attrs
        |> Accounts.create_account_with_owner(identity.id)

      assert {:ok, %Workspace{} = workspace} =
               Workspaces.create_workspace_with_account_and_owner(
                 @valid_attrs,
                 account.id,
                 identity.id
               )

      assert workspace.name == "some name"
    end

    test "create_workspace/1 with invalid data returns error changeset" do
      {:ok, identity} =
        @identity_attrs
        |> Identities.register_identity()

      {:ok, account} =
        @account_attrs
        |> Accounts.create_account_with_owner(identity.id)

      assert {:error, %Ecto.Changeset{}} =
               Workspaces.create_workspace_with_account_and_owner(
                 @invalid_attrs,
                 account.id,
                 identity.id
               )
    end

    test "update_workspace/2 with valid data updates the workspace" do
      workspace = workspace_fixture()

      assert {:ok, %Workspace{} = workspace} =
               Workspaces.update_workspace(workspace, @update_attrs)

      assert workspace.name == "some updated name"
    end

    test "update_workspace/2 with invalid data returns error changeset" do
      %{id: id, name: name} = workspace = workspace_fixture()
      assert {:error, %Ecto.Changeset{}} = Workspaces.update_workspace(workspace, @invalid_attrs)
      assert %{id: ^id, name: ^name} = Workspaces.get_workspace!(id)
    end

    test "delete_workspace/1 deletes the workspace" do
      workspace = workspace_fixture()
      assert {:ok, %Workspace{}} = Workspaces.delete_workspace(workspace)
      assert_raise Ecto.NoResultsError, fn -> Workspaces.get_workspace!(workspace.id) end
    end

    test "change_workspace/1 returns a workspace changeset" do
      workspace = workspace_fixture()
      assert %Ecto.Changeset{} = Workspaces.change_workspace(workspace)
    end
  end
end
