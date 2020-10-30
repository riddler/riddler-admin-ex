defmodule RiddlerAdmin.EnvironmentsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Environments

  describe "environments" do
    alias RiddlerAdmin.Environments.Environment

    @valid_attrs %{key: "some key", name: "some name"}
    @update_attrs %{key: "some updated key", name: "some updated name"}
    @invalid_attrs %{key: nil, name: nil}

    def environment_fixture(attrs \\ %{}) do
      {:ok, environment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Environments.create_environment()

      environment
    end

    test "list_environments/0 returns all environments" do
      environment = environment_fixture()
      assert Environments.list_environments() == [environment]
    end

    test "get_environment!/1 returns the environment with given id" do
      environment = environment_fixture()
      assert Environments.get_environment!(environment.id) == environment
    end

    test "create_environment/1 with valid data creates a environment" do
      assert {:ok, %Environment{} = environment} = Environments.create_environment(@valid_attrs)
      assert environment.key == "some key"
      assert environment.name == "some name"
    end

    test "create_environment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Environments.create_environment(@invalid_attrs)
    end

    test "update_environment/2 with valid data updates the environment" do
      environment = environment_fixture()
      assert {:ok, %Environment{} = environment} = Environments.update_environment(environment, @update_attrs)
      assert environment.key == "some updated key"
      assert environment.name == "some updated name"
    end

    test "update_environment/2 with invalid data returns error changeset" do
      environment = environment_fixture()
      assert {:error, %Ecto.Changeset{}} = Environments.update_environment(environment, @invalid_attrs)
      assert environment == Environments.get_environment!(environment.id)
    end

    test "delete_environment/1 deletes the environment" do
      environment = environment_fixture()
      assert {:ok, %Environment{}} = Environments.delete_environment(environment)
      assert_raise Ecto.NoResultsError, fn -> Environments.get_environment!(environment.id) end
    end

    test "change_environment/1 returns a environment changeset" do
      environment = environment_fixture()
      assert %Ecto.Changeset{} = Environments.change_environment(environment)
    end
  end
end
