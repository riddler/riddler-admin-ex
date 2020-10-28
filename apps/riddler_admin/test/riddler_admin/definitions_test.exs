defmodule RiddlerAdmin.DefinitionsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Definitions

  describe "definitions" do
    alias RiddlerAdmin.Definitions.Definition

    @valid_attrs %{data: %{}, schema_version: 42, version: 42}
    @update_attrs %{data: %{}, schema_version: 43, version: 43}
    @invalid_attrs %{data: nil, schema_version: nil, version: nil}

    def definition_fixture(attrs \\ %{}) do
      {:ok, definition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Definitions.create_definition()

      definition
    end

    test "list_definitions/0 returns all definitions" do
      definition = definition_fixture()
      assert Definitions.list_definitions() == [definition]
    end

    test "get_definition!/1 returns the definition with given id" do
      definition = definition_fixture()
      assert Definitions.get_definition!(definition.id) == definition
    end

    test "create_definition/1 with valid data creates a definition" do
      assert {:ok, %Definition{} = definition} = Definitions.create_definition(@valid_attrs)
      assert definition.data == %{}
      assert definition.schema_version == 42
      assert definition.version == 42
    end

    test "create_definition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Definitions.create_definition(@invalid_attrs)
    end

    test "update_definition/2 with valid data updates the definition" do
      definition = definition_fixture()
      assert {:ok, %Definition{} = definition} = Definitions.update_definition(definition, @update_attrs)
      assert definition.data == %{}
      assert definition.schema_version == 43
      assert definition.version == 43
    end

    test "update_definition/2 with invalid data returns error changeset" do
      definition = definition_fixture()
      assert {:error, %Ecto.Changeset{}} = Definitions.update_definition(definition, @invalid_attrs)
      assert definition == Definitions.get_definition!(definition.id)
    end

    test "delete_definition/1 deletes the definition" do
      definition = definition_fixture()
      assert {:ok, %Definition{}} = Definitions.delete_definition(definition)
      assert_raise Ecto.NoResultsError, fn -> Definitions.get_definition!(definition.id) end
    end

    test "change_definition/1 returns a definition changeset" do
      definition = definition_fixture()
      assert %Ecto.Changeset{} = Definitions.change_definition(definition)
    end
  end
end
