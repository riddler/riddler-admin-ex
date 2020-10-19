defmodule RiddlerAdmin.ConditionsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Conditions

  describe "conditions" do
    alias RiddlerAdmin.Conditions.Condition

    @valid_attrs %{key: "some key", source: "some source"}
    @update_attrs %{key: "some updated key", source: "some updated source"}
    @invalid_attrs %{key: nil, source: nil}

    def condition_fixture(attrs \\ %{}) do
      {:ok, condition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Conditions.create_condition()

      condition
    end

    test "list_conditions/0 returns all conditions" do
      condition = condition_fixture()
      assert Conditions.list_conditions() == [condition]
    end

    test "get_condition!/1 returns the condition with given id" do
      condition = condition_fixture()
      assert Conditions.get_condition!(condition.id) == condition
    end

    test "create_condition/1 with valid data creates a condition" do
      assert {:ok, %Condition{} = condition} = Conditions.create_condition(@valid_attrs)
      assert condition.key == "some key"
      assert condition.source == "some source"
    end

    test "create_condition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conditions.create_condition(@invalid_attrs)
    end

    test "update_condition/2 with valid data updates the condition" do
      condition = condition_fixture()
      assert {:ok, %Condition{} = condition} = Conditions.update_condition(condition, @update_attrs)
      assert condition.key == "some updated key"
      assert condition.source == "some updated source"
    end

    test "update_condition/2 with invalid data returns error changeset" do
      condition = condition_fixture()
      assert {:error, %Ecto.Changeset{}} = Conditions.update_condition(condition, @invalid_attrs)
      assert condition == Conditions.get_condition!(condition.id)
    end

    test "delete_condition/1 deletes the condition" do
      condition = condition_fixture()
      assert {:ok, %Condition{}} = Conditions.delete_condition(condition)
      assert_raise Ecto.NoResultsError, fn -> Conditions.get_condition!(condition.id) end
    end

    test "change_condition/1 returns a condition changeset" do
      condition = condition_fixture()
      assert %Ecto.Changeset{} = Conditions.change_condition(condition)
    end
  end
end
