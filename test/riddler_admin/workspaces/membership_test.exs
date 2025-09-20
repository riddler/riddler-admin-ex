defmodule RiddlerAdmin.Workspaces.MembershipTest do
  use RiddlerAdmin.DataCase, async: true

  alias RiddlerAdmin.Workspaces.Membership

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      user = insert(:user)
      workspace = insert(:workspace)

      attrs = %{
        role: :admin,
        user_id: user.id,
        workspace_id: workspace.id
      }

      changeset = Membership.changeset(%Membership{}, attrs)

      assert changeset.valid?
      assert changeset.changes.role == :admin
      assert changeset.changes.user_id == user.id
      assert changeset.changes.workspace_id == workspace.id
    end

    test "invalid changeset when role is missing" do
      user = insert(:user)
      workspace = insert(:workspace)

      attrs = %{
        user_id: user.id,
        workspace_id: workspace.id
      }

      changeset = Membership.changeset(%Membership{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:role]
    end

    test "invalid changeset when user_id is missing" do
      workspace = insert(:workspace)

      attrs = %{
        role: :member,
        workspace_id: workspace.id
      }

      changeset = Membership.changeset(%Membership{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:user_id]
    end

    test "invalid changeset when workspace_id is missing" do
      user = insert(:user)

      attrs = %{
        role: :member,
        user_id: user.id
      }

      changeset = Membership.changeset(%Membership{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:workspace_id]
    end

    test "invalid changeset when role is not in allowed values" do
      user = insert(:user)
      workspace = insert(:workspace)

      attrs = %{
        role: :invalid_role,
        user_id: user.id,
        workspace_id: workspace.id
      }

      changeset = Membership.changeset(%Membership{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:role]
    end
  end

  describe "roles/0" do
    test "returns list of available roles" do
      roles = Membership.roles()

      assert :admin in roles
      assert :member in roles
      assert is_list(roles)
    end
  end

  describe "admin?/1" do
    test "returns true for admin role" do
      assert Membership.admin?(:admin)
    end

    test "returns false for member role" do
      refute Membership.admin?(:member)
    end

    test "returns false for other roles" do
      refute Membership.admin?(:other)
      refute Membership.admin?(nil)
    end
  end

  describe "member?/1" do
    test "returns true for member role" do
      assert Membership.member?(:member)
    end

    test "returns false for admin role" do
      refute Membership.member?(:admin)
    end

    test "returns false for other roles" do
      refute Membership.member?(:other)
      refute Membership.member?(nil)
    end
  end
end
