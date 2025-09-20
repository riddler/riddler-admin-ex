defmodule RiddlerAdmin.Accounts.ScopeTest do
  use RiddlerAdmin.DataCase, async: true

  alias RiddlerAdmin.Accounts.Scope

  describe "for_user/1" do
    test "creates scope with user" do
      user = insert(:user)
      scope = Scope.for_user(user)

      assert scope.user == user
      assert is_nil(scope.workspace)
    end

    test "returns nil when given nil" do
      assert Scope.for_user(nil) == nil
    end
  end

  describe "for_user_and_workspace/2" do
    test "creates scope with user and workspace" do
      user = insert(:user)
      workspace = insert(:workspace)
      scope = Scope.for_user_and_workspace(user, workspace)

      assert scope.user == user
      assert scope.workspace == workspace
    end
  end

  describe "with_workspace/2" do
    test "adds workspace to existing scope" do
      user = insert(:user)
      workspace = insert(:workspace)
      scope = Scope.for_user(user)

      updated_scope = Scope.with_workspace(scope, workspace)

      assert updated_scope.user == user
      assert updated_scope.workspace == workspace
    end
  end

  describe "sysadmin?/1" do
    test "returns true when user is sysadmin" do
      sysadmin = insert(:user, sysadmin: true)
      scope = Scope.for_user(sysadmin)

      assert Scope.sysadmin?(scope)
    end

    test "returns false when user is not sysadmin" do
      user = insert(:user, sysadmin: false)
      scope = Scope.for_user(user)

      refute Scope.sysadmin?(scope)
    end

    test "returns false when no user in scope" do
      scope = %Scope{}

      refute Scope.sysadmin?(scope)
    end
  end

  describe "has_workspace?/1" do
    test "returns true when workspace is present" do
      user = insert(:user)
      workspace = insert(:workspace)
      scope = Scope.for_user_and_workspace(user, workspace)

      assert Scope.has_workspace?(scope)
    end

    test "returns false when no workspace in scope" do
      user = insert(:user)
      scope = Scope.for_user(user)

      refute Scope.has_workspace?(scope)
    end

    test "returns false when scope has no workspace field" do
      scope = %Scope{}

      refute Scope.has_workspace?(scope)
    end
  end
end
