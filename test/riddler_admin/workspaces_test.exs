defmodule RiddlerAdmin.WorkspacesTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Accounts.Scope
  alias RiddlerAdmin.Factory
  alias RiddlerAdmin.Workspaces

  describe "list_workspaces/0" do
    test "returns all workspaces" do
      workspace1 = Factory.insert(:workspace)
      workspace2 = Factory.insert(:workspace)

      workspaces = Workspaces.list_workspaces()

      assert length(workspaces) == 2
      assert Enum.member?(workspaces, workspace1)
      assert Enum.member?(workspaces, workspace2)
    end

    test "returns empty list when no workspaces exist" do
      assert Workspaces.list_workspaces() == []
    end
  end

  describe "list_workspaces_for_user/1" do
    test "returns workspaces where user is a member" do
      user = Factory.insert(:user)
      other_user = Factory.insert(:user)

      workspace1 = Factory.insert(:workspace)
      workspace2 = Factory.insert(:workspace)
      workspace3 = Factory.insert(:workspace)

      Factory.insert(:membership, user: user, workspace: workspace1, role: :admin)
      Factory.insert(:membership, user: user, workspace: workspace2, role: :member)
      Factory.insert(:membership, user: other_user, workspace: workspace3, role: :admin)

      workspaces = Workspaces.list_workspaces_for_user(user)

      assert length(workspaces) == 2
      assert Enum.member?(workspaces, workspace1)
      assert Enum.member?(workspaces, workspace2)
      refute Enum.member?(workspaces, workspace3)
    end

    test "returns empty list when user has no memberships" do
      user = Factory.insert(:user)
      Factory.insert(:workspace)

      assert Workspaces.list_workspaces_for_user(user) == []
    end
  end

  describe "get_workspace!/1" do
    test "returns workspace with valid id" do
      workspace = Factory.insert(:workspace)
      assert Workspaces.get_workspace!(workspace.id) == workspace
    end

    test "raises when workspace does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Workspaces.get_workspace!("nonexistent")
      end
    end
  end

  describe "get_workspace_by_slug/1" do
    test "returns workspace with valid slug" do
      workspace = Factory.insert(:workspace, slug: "test-workspace")
      assert Workspaces.get_workspace_by_slug("test-workspace") == workspace
    end

    test "returns nil when workspace does not exist" do
      assert Workspaces.get_workspace_by_slug("nonexistent") == nil
    end
  end

  describe "get_workspace_by_slug!/1" do
    test "returns workspace with valid slug" do
      workspace = Factory.insert(:workspace, slug: "test-workspace")
      assert Workspaces.get_workspace_by_slug!("test-workspace") == workspace
    end

    test "raises when workspace does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Workspaces.get_workspace_by_slug!("nonexistent")
      end
    end
  end

  describe "create_workspace/2" do
    test "creates workspace when user is authorized" do
      user = Factory.insert(:user)
      scope = Scope.for_user(user)

      attrs = %{name: "Test Workspace", slug: "test-workspace"}

      assert {:ok, workspace} = Workspaces.create_workspace(scope, attrs)
      assert workspace.name == "Test Workspace"
      assert workspace.slug == "test-workspace"

      # Check that creator is added as admin
      membership = Workspaces.get_membership(user, workspace)
      assert membership.role == :admin
    end

    test "returns error when workspace attributes are invalid" do
      user = Factory.insert(:user)
      scope = Scope.for_user(user)

      attrs = %{name: "", slug: ""}

      assert {:error, changeset} = Workspaces.create_workspace(scope, attrs)
      assert changeset.errors[:name]
      assert changeset.errors[:slug]
    end

    test "returns error when slug is not unique" do
      Factory.insert(:workspace, slug: "duplicate-slug")
      user = Factory.insert(:user)
      scope = Scope.for_user(user)

      attrs = %{name: "Another Workspace", slug: "duplicate-slug"}

      assert {:error, changeset} = Workspaces.create_workspace(scope, attrs)
      assert changeset.errors[:slug]
    end
  end

  describe "update_workspace/3" do
    test "updates workspace when user is admin" do
      workspace = Factory.insert(:workspace, name: "Old Name")
      admin_user = Factory.insert(:user)
      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)
      scope = Scope.for_user(admin_user)

      attrs = %{name: "New Name"}

      assert {:ok, updated_workspace} = Workspaces.update_workspace(scope, workspace, attrs)
      assert updated_workspace.name == "New Name"
    end

    test "returns unauthorized when user is not admin" do
      workspace = Factory.insert(:workspace)
      member_user = Factory.insert(:user)
      Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)
      scope = Scope.for_user(member_user)

      attrs = %{name: "New Name"}

      assert {:error, :unauthorized} = Workspaces.update_workspace(scope, workspace, attrs)
    end

    test "returns unauthorized when user is not a member" do
      workspace = Factory.insert(:workspace)
      non_member_user = Factory.insert(:user)
      scope = Scope.for_user(non_member_user)

      attrs = %{name: "New Name"}

      assert {:error, :unauthorized} = Workspaces.update_workspace(scope, workspace, attrs)
    end

    test "allows sysadmin to update any workspace" do
      workspace = Factory.insert(:workspace, name: "Old Name")
      sysadmin = Factory.insert(:user, sysadmin: true)
      scope = Scope.for_user(sysadmin)

      attrs = %{name: "New Name"}

      assert {:ok, updated_workspace} = Workspaces.update_workspace(scope, workspace, attrs)
      assert updated_workspace.name == "New Name"
    end
  end

  describe "delete_workspace/2" do
    test "deletes workspace when user is admin" do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)
      scope = Scope.for_user(admin_user)

      assert {:ok, deleted_workspace} = Workspaces.delete_workspace(scope, workspace)
      assert deleted_workspace.id == workspace.id

      assert_raise Ecto.NoResultsError, fn ->
        Workspaces.get_workspace!(workspace.id)
      end
    end

    test "returns unauthorized when user is not admin" do
      workspace = Factory.insert(:workspace)
      member_user = Factory.insert(:user)
      Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)
      scope = Scope.for_user(member_user)

      assert {:error, :unauthorized} = Workspaces.delete_workspace(scope, workspace)
    end

    test "allows sysadmin to delete any workspace" do
      workspace = Factory.insert(:workspace)
      sysadmin = Factory.insert(:user, sysadmin: true)
      scope = Scope.for_user(sysadmin)

      assert {:ok, deleted_workspace} = Workspaces.delete_workspace(scope, workspace)
      assert deleted_workspace.id == workspace.id
    end
  end

  describe "change_workspace/2" do
    test "returns a workspace changeset" do
      workspace = Factory.build(:workspace)
      changeset = Workspaces.change_workspace(workspace)
      assert %Ecto.Changeset{} = changeset
      assert changeset.data == workspace
    end
  end

  describe "list_memberships/2" do
    test "returns memberships when user is a member" do
      workspace = Factory.insert(:workspace)
      user1 = Factory.insert(:user)
      user2 = Factory.insert(:user)
      requesting_user = Factory.insert(:user)

      membership1 = Factory.insert(:membership, user: user1, workspace: workspace, role: :admin)
      membership2 = Factory.insert(:membership, user: user2, workspace: workspace, role: :member)
      Factory.insert(:membership, user: requesting_user, workspace: workspace, role: :member)

      scope = Scope.for_user(requesting_user)

      assert {:ok, memberships} = Workspaces.list_memberships(scope, workspace)
      assert length(memberships) == 3

      membership_ids = Enum.map(memberships, & &1.id)
      assert membership1.id in membership_ids
      assert membership2.id in membership_ids
    end

    test "returns unauthorized when user is not a member" do
      workspace = Factory.insert(:workspace)
      non_member_user = Factory.insert(:user)
      Factory.insert(:membership, workspace: workspace)

      scope = Scope.for_user(non_member_user)

      assert {:error, :unauthorized} = Workspaces.list_memberships(scope, workspace)
    end

    test "allows sysadmin to list any workspace memberships" do
      workspace = Factory.insert(:workspace)
      sysadmin = Factory.insert(:user, sysadmin: true)
      Factory.insert(:membership, workspace: workspace)

      scope = Scope.for_user(sysadmin)

      assert {:ok, memberships} = Workspaces.list_memberships(scope, workspace)
      assert length(memberships) == 1
    end
  end

  describe "get_membership/2" do
    test "returns membership when user belongs to workspace" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)
      membership = Factory.insert(:membership, user: user, workspace: workspace, role: :admin)

      found_membership = Workspaces.get_membership(user, workspace)
      assert found_membership.id == membership.id
      assert found_membership.role == :admin
    end

    test "returns nil when user does not belong to workspace" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)

      assert Workspaces.get_membership(user, workspace) == nil
    end
  end

  describe "get_membership_by_slug/2" do
    test "returns membership when user belongs to workspace with slug" do
      workspace = Factory.insert(:workspace, slug: "test-workspace")
      user = Factory.insert(:user)
      membership = Factory.insert(:membership, user: user, workspace: workspace, role: :member)

      found_membership = Workspaces.get_membership_by_slug(user, "test-workspace")
      assert found_membership.id == membership.id
      assert found_membership.workspace.id == workspace.id
    end

    test "returns nil when user does not belong to workspace" do
      Factory.insert(:workspace, slug: "test-workspace")
      user = Factory.insert(:user)

      assert Workspaces.get_membership_by_slug(user, "test-workspace") == nil
    end

    test "returns nil when workspace does not exist" do
      user = Factory.insert(:user)

      assert Workspaces.get_membership_by_slug(user, "nonexistent") == nil
    end
  end

  describe "create_membership/4" do
    test "creates membership when user is admin" do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      new_user = Factory.insert(:user)
      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      scope = Scope.for_user(admin_user)

      assert {:ok, membership} = Workspaces.create_membership(scope, new_user, workspace, :member)
      assert membership.user_id == new_user.id
      assert membership.workspace_id == workspace.id
      assert membership.role == :member
    end

    test "returns unauthorized when user is not admin" do
      workspace = Factory.insert(:workspace)
      member_user = Factory.insert(:user)
      new_user = Factory.insert(:user)
      Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      scope = Scope.for_user(member_user)

      assert {:error, :unauthorized} =
               Workspaces.create_membership(scope, new_user, workspace, :member)
    end

    test "allows sysadmin to create membership in any workspace" do
      workspace = Factory.insert(:workspace)
      sysadmin = Factory.insert(:user, sysadmin: true)
      new_user = Factory.insert(:user)

      scope = Scope.for_user(sysadmin)

      assert {:ok, membership} = Workspaces.create_membership(scope, new_user, workspace, :admin)
      assert membership.role == :admin
    end
  end

  describe "update_membership/3" do
    test "updates membership when user is admin" do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      member_user = Factory.insert(:user)
      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      membership =
        Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      scope = Scope.for_user(admin_user)

      assert {:ok, updated_membership} =
               Workspaces.update_membership(scope, membership, %{role: :admin})

      assert updated_membership.role == :admin
    end

    test "returns unauthorized when user is not admin" do
      workspace = Factory.insert(:workspace)
      member_user = Factory.insert(:user)
      other_user = Factory.insert(:user)
      Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      membership =
        Factory.insert(:membership, user: other_user, workspace: workspace, role: :member)

      scope = Scope.for_user(member_user)

      assert {:error, :unauthorized} =
               Workspaces.update_membership(scope, membership, %{role: :admin})
    end

    test "allows sysadmin to update any membership" do
      workspace = Factory.insert(:workspace)
      sysadmin = Factory.insert(:user, sysadmin: true)
      member_user = Factory.insert(:user)

      membership =
        Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      scope = Scope.for_user(sysadmin)

      assert {:ok, updated_membership} =
               Workspaces.update_membership(scope, membership, %{role: :admin})

      assert updated_membership.role == :admin
    end
  end

  describe "delete_membership/2" do
    test "deletes membership when user is admin" do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      member_user = Factory.insert(:user)
      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      membership =
        Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      scope = Scope.for_user(admin_user)

      assert {:ok, deleted_membership} = Workspaces.delete_membership(scope, membership)
      assert deleted_membership.id == membership.id
      assert Workspaces.get_membership(member_user, workspace) == nil
    end

    test "returns unauthorized when user is not admin" do
      workspace = Factory.insert(:workspace)
      member_user = Factory.insert(:user)
      other_user = Factory.insert(:user)
      Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      membership =
        Factory.insert(:membership, user: other_user, workspace: workspace, role: :member)

      scope = Scope.for_user(member_user)

      assert {:error, :unauthorized} = Workspaces.delete_membership(scope, membership)
    end

    test "allows sysadmin to delete any membership" do
      workspace = Factory.insert(:workspace)
      sysadmin = Factory.insert(:user, sysadmin: true)
      member_user = Factory.insert(:user)

      membership =
        Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      scope = Scope.for_user(sysadmin)

      assert {:ok, deleted_membership} = Workspaces.delete_membership(scope, membership)
      assert deleted_membership.id == membership.id
    end
  end

  describe "change_membership/2" do
    test "returns a membership changeset" do
      membership = Factory.build(:membership)
      changeset = Workspaces.change_membership(membership)
      assert %Ecto.Changeset{} = changeset
      assert changeset.data == membership
    end
  end

  describe "authorization helpers" do
    test "member?/2 returns true when user is a member" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)
      Factory.insert(:membership, user: user, workspace: workspace, role: :member)

      assert Workspaces.member?(user, workspace)
    end

    test "member?/2 returns false when user is not a member" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)

      refute Workspaces.member?(user, workspace)
    end

    test "admin?/2 returns true when user is an admin" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)
      Factory.insert(:membership, user: user, workspace: workspace, role: :admin)

      assert Workspaces.admin?(user, workspace)
    end

    test "admin?/2 returns false when user is a member but not admin" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)
      Factory.insert(:membership, user: user, workspace: workspace, role: :member)

      refute Workspaces.admin?(user, workspace)
    end

    test "admin?/2 returns false when user is not a member" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)

      refute Workspaces.admin?(user, workspace)
    end

    test "can_access?/2 returns true for sysadmin" do
      workspace = Factory.insert(:workspace)
      sysadmin = Factory.insert(:user, sysadmin: true)

      assert Workspaces.can_access?(sysadmin, workspace)
    end

    test "can_access?/2 returns true for workspace members" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)
      Factory.insert(:membership, user: user, workspace: workspace, role: :member)

      assert Workspaces.can_access?(user, workspace)
    end

    test "can_access?/2 returns false for non-members" do
      workspace = Factory.insert(:workspace)
      user = Factory.insert(:user)

      refute Workspaces.can_access?(user, workspace)
    end
  end
end
