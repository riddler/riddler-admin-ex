defmodule RiddlerAdmin.AccountsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Accounts
  alias RiddlerAdmin.Identities

  describe "accounts" do
    alias RiddlerAdmin.Accounts.Account

    @identity_attrs %{email: "foo@bar.com", password: "Zaq1Xsw2Cde3"}

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, identity} = Identities.register_identity(@identity_attrs)

      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account_with_owner(identity.id)

      account
    end

    test "list_accounts/0 returns all accounts" do
      %{name: name} = account_fixture()

      assert [
               %{
                 name: ^name
               }
             ] = Accounts.list_accounts()
    end

    test "get_account!/1 returns the account with given id" do
      %{
        id: id,
        name: name
      } = account_fixture()

      assert %{
               name: ^name
             } = Accounts.get_account!(id)
    end

    test "create_account/2 with valid data creates a account" do
      {:ok, identity} = Identities.register_identity(@identity_attrs)

      assert {:ok, %Account{} = account} =
               Accounts.create_account_with_owner(@valid_attrs, identity.id)

      assert account.name == "some name"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_account_with_owner(@invalid_attrs, "bad id")
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Accounts.update_account(account, @update_attrs)
      assert account.name == "some updated name"
    end

    test "update_account/2 with invalid data returns error changeset" do
      %{id: id, name: name} = account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert %{name: ^name} = Accounts.get_account!(id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end
end
