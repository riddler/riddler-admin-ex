defmodule RiddlerAdmin.FlagsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Flags

  describe "flags" do
    alias RiddlerAdmin.Flags.Flag

    @valid_attrs %{key: "some key", type: "some type"}
    @update_attrs %{key: "some updated key", type: "some updated type"}
    @invalid_attrs %{key: nil, type: nil}

    def flag_fixture(attrs \\ %{}) do
      {:ok, flag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Flags.create_flag()

      flag
    end

    test "list_flags/0 returns all flags" do
      flag = flag_fixture()
      assert Flags.list_flags() == [flag]
    end

    test "get_flag!/1 returns the flag with given id" do
      flag = flag_fixture()
      assert Flags.get_flag!(flag.id) == flag
    end

    test "create_flag/1 with valid data creates a flag" do
      assert {:ok, %Flag{} = flag} = Flags.create_flag(@valid_attrs)
      assert flag.key == "some key"
      assert flag.type == "some type"
    end

    test "create_flag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Flags.create_flag(@invalid_attrs)
    end

    test "update_flag/2 with valid data updates the flag" do
      flag = flag_fixture()
      assert {:ok, %Flag{} = flag} = Flags.update_flag(flag, @update_attrs)
      assert flag.key == "some updated key"
      assert flag.type == "some updated type"
    end

    test "update_flag/2 with invalid data returns error changeset" do
      flag = flag_fixture()
      assert {:error, %Ecto.Changeset{}} = Flags.update_flag(flag, @invalid_attrs)
      assert flag == Flags.get_flag!(flag.id)
    end

    test "delete_flag/1 deletes the flag" do
      flag = flag_fixture()
      assert {:ok, %Flag{}} = Flags.delete_flag(flag)
      assert_raise Ecto.NoResultsError, fn -> Flags.get_flag!(flag.id) end
    end

    test "change_flag/1 returns a flag changeset" do
      flag = flag_fixture()
      assert %Ecto.Changeset{} = Flags.change_flag(flag)
    end
  end
end
