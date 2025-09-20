defmodule RiddlerAdmin.AuthorizationTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Authorization
  alias RiddlerAdmin.Factory

  describe "sysadmin authorization" do
    test "sysadmin can perform any action on any resource" do
      sysadmin = Factory.build(:user, sysadmin: true)
      workspace = Factory.build(:workspace)
      membership = Factory.build(:membership)

      # Workspace actions
      assert :ok == Authorization.authorize(:create_workspace, sysadmin, workspace)
      assert :ok == Authorization.authorize(:read_workspace, sysadmin, workspace)
      assert :ok == Authorization.authorize(:update_workspace, sysadmin, workspace)
      assert :ok == Authorization.authorize(:delete_workspace, sysadmin, workspace)
      assert :ok == Authorization.authorize(:manage_workspace, sysadmin, workspace)

      # Membership actions
      assert :ok == Authorization.authorize(:list_memberships, sysadmin, workspace)
      assert :ok == Authorization.authorize(:read_membership, sysadmin, membership)
      assert :ok == Authorization.authorize(:create_membership, sysadmin, workspace)
      assert :ok == Authorization.authorize(:update_membership, sysadmin, membership)
      assert :ok == Authorization.authorize(:delete_membership, sysadmin, membership)

      # Random actions should also work
      assert :ok == Authorization.authorize(:random_action, sysadmin, workspace)
    end
  end

  describe "workspace authorization" do
    setup do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      member_user = Factory.insert(:user)
      non_member_user = Factory.insert(:user)

      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)
      Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      %{
        workspace: workspace,
        admin_user: admin_user,
        member_user: member_user,
        non_member_user: non_member_user
      }
    end

    test "any authenticated user can create workspaces" do
      user = Factory.build(:user)
      workspace = Factory.build(:workspace)

      assert :ok == Authorization.authorize(:create_workspace, user, workspace)
    end

    test "workspace members can read workspaces", %{
      workspace: workspace,
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user
    } do
      assert :ok == Authorization.authorize(:read_workspace, admin_user, workspace)
      assert :ok == Authorization.authorize(:read_workspace, member_user, workspace)
      assert :error == Authorization.authorize(:read_workspace, non_member_user, workspace)
    end

    test "only workspace admins can update workspaces", %{
      workspace: workspace,
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user
    } do
      assert :ok == Authorization.authorize(:update_workspace, admin_user, workspace)
      assert :error == Authorization.authorize(:update_workspace, member_user, workspace)
      assert :error == Authorization.authorize(:update_workspace, non_member_user, workspace)
    end

    test "only workspace admins can delete workspaces", %{
      workspace: workspace,
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user
    } do
      assert :ok == Authorization.authorize(:delete_workspace, admin_user, workspace)
      assert :error == Authorization.authorize(:delete_workspace, member_user, workspace)
      assert :error == Authorization.authorize(:delete_workspace, non_member_user, workspace)
    end

    test "only workspace admins can manage workspaces", %{
      workspace: workspace,
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user
    } do
      assert :ok == Authorization.authorize(:manage_workspace, admin_user, workspace)
      assert :error == Authorization.authorize(:manage_workspace, member_user, workspace)
      assert :error == Authorization.authorize(:manage_workspace, non_member_user, workspace)
    end
  end

  describe "membership authorization" do
    setup do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      member_user = Factory.insert(:user)
      non_member_user = Factory.insert(:user)

      admin_membership =
        Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      member_membership =
        Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      %{
        workspace: workspace,
        admin_user: admin_user,
        member_user: member_user,
        non_member_user: non_member_user,
        admin_membership: admin_membership,
        member_membership: member_membership
      }
    end

    test "workspace members can list memberships", %{
      workspace: workspace,
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user
    } do
      assert :ok == Authorization.authorize(:list_memberships, admin_user, workspace)
      assert :ok == Authorization.authorize(:list_memberships, member_user, workspace)
      assert :error == Authorization.authorize(:list_memberships, non_member_user, workspace)
    end

    test "workspace members can read individual memberships", %{
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user,
      admin_membership: admin_membership
    } do
      assert :ok == Authorization.authorize(:read_membership, admin_user, admin_membership)
      assert :ok == Authorization.authorize(:read_membership, member_user, admin_membership)

      assert :error ==
               Authorization.authorize(:read_membership, non_member_user, admin_membership)
    end

    test "only workspace admins can create memberships", %{
      workspace: workspace,
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user
    } do
      assert :ok == Authorization.authorize(:create_membership, admin_user, workspace)
      assert :error == Authorization.authorize(:create_membership, member_user, workspace)
      assert :error == Authorization.authorize(:create_membership, non_member_user, workspace)
    end

    test "only workspace admins can update memberships", %{
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user,
      member_membership: member_membership
    } do
      assert :ok == Authorization.authorize(:update_membership, admin_user, member_membership)
      assert :error == Authorization.authorize(:update_membership, member_user, member_membership)

      assert :error ==
               Authorization.authorize(:update_membership, non_member_user, member_membership)
    end

    test "only workspace admins can delete memberships", %{
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user,
      member_membership: member_membership
    } do
      assert :ok == Authorization.authorize(:delete_membership, admin_user, member_membership)
      assert :error == Authorization.authorize(:delete_membership, member_user, member_membership)

      assert :error ==
               Authorization.authorize(:delete_membership, non_member_user, member_membership)
    end
  end

  describe "convenience functions" do
    setup do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      member_user = Factory.insert(:user)
      non_member_user = Factory.insert(:user)
      sysadmin = Factory.insert(:user, sysadmin: true)

      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)
      Factory.insert(:membership, user: member_user, workspace: workspace, role: :member)

      %{
        workspace: workspace,
        admin_user: admin_user,
        member_user: member_user,
        non_member_user: non_member_user,
        sysadmin: sysadmin
      }
    end

    test "can_access_workspace?/2 returns boolean", %{
      workspace: workspace,
      admin_user: admin_user,
      member_user: member_user,
      non_member_user: non_member_user,
      sysadmin: sysadmin
    } do
      assert Authorization.can_access_workspace?(admin_user, workspace)
      assert Authorization.can_access_workspace?(member_user, workspace)
      refute Authorization.can_access_workspace?(non_member_user, workspace)
      assert Authorization.can_access_workspace?(sysadmin, workspace)
    end

    test "sysadmin?/1 returns boolean" do
      regular_user = Factory.build(:user, sysadmin: false)
      sysadmin_user = Factory.build(:user, sysadmin: true)

      refute Authorization.sysadmin?(regular_user)
      assert Authorization.sysadmin?(sysadmin_user)
    end
  end

  describe "default deny behavior" do
    test "unknown actions are denied" do
      user = Factory.build(:user)
      workspace = Factory.build(:workspace)

      assert :error == Authorization.authorize(:unknown_action, user, workspace)
      assert :error == Authorization.authorize(:random_stuff, user, workspace)
    end
  end

  describe "using Bodyguard.permit/3" do
    setup do
      workspace = Factory.insert(:workspace)
      admin_user = Factory.insert(:user)
      non_member_user = Factory.insert(:user)
      sysadmin = Factory.insert(:user, sysadmin: true)

      Factory.insert(:membership, user: admin_user, workspace: workspace, role: :admin)

      %{
        workspace: workspace,
        admin_user: admin_user,
        non_member_user: non_member_user,
        sysadmin: sysadmin
      }
    end

    test "Bodyguard.permit/3 works with successful actions", %{
      workspace: workspace,
      admin_user: admin_user,
      sysadmin: sysadmin
    } do
      assert :ok == Bodyguard.permit(Authorization, :update_workspace, admin_user, workspace)
      assert :ok == Bodyguard.permit(Authorization, :read_workspace, sysadmin, workspace)
    end

    test "Bodyguard.permit/3 returns error for unauthorized actions", %{
      workspace: workspace,
      non_member_user: non_member_user
    } do
      assert {:error, :unauthorized} ==
               Bodyguard.permit(Authorization, :update_workspace, non_member_user, workspace)
    end

    test "Bodyguard.permit?/3 returns boolean", %{
      workspace: workspace,
      admin_user: admin_user,
      non_member_user: non_member_user
    } do
      assert Bodyguard.permit?(Authorization, :update_workspace, admin_user, workspace)
      refute Bodyguard.permit?(Authorization, :update_workspace, non_member_user, workspace)
    end

    test "Bodyguard.permit!/3 raises on unauthorized actions", %{
      workspace: workspace,
      non_member_user: non_member_user
    } do
      error =
        assert_raise Bodyguard.NotAuthorizedError, fn ->
          Bodyguard.permit!(Authorization, :update_workspace, non_member_user, workspace)
        end

      assert %{status: 403, message: "not authorized"} = error
    end
  end
end
