defmodule RiddlerAdmin.PreviewsTest do
  use RiddlerAdmin.DataCase

  alias RiddlerAdmin.Previews

  describe "previews" do
    alias RiddlerAdmin.Previews.Preview

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def preview_fixture(attrs \\ %{}) do
      {:ok, preview} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Previews.create_preview()

      preview
    end

    test "list_previews/0 returns all previews" do
      preview = preview_fixture()
      assert Previews.list_previews() == [preview]
    end

    test "get_preview!/1 returns the preview with given id" do
      preview = preview_fixture()
      assert Previews.get_preview!(preview.id) == preview
    end

    test "create_preview/1 with valid data creates a preview" do
      assert {:ok, %Preview{} = preview} = Previews.create_preview(@valid_attrs)
    end

    test "create_preview/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Previews.create_preview(@invalid_attrs)
    end

    test "update_preview/2 with valid data updates the preview" do
      preview = preview_fixture()
      assert {:ok, %Preview{} = preview} = Previews.update_preview(preview, @update_attrs)
    end

    test "update_preview/2 with invalid data returns error changeset" do
      preview = preview_fixture()
      assert {:error, %Ecto.Changeset{}} = Previews.update_preview(preview, @invalid_attrs)
      assert preview == Previews.get_preview!(preview.id)
    end

    test "delete_preview/1 deletes the preview" do
      preview = preview_fixture()
      assert {:ok, %Preview{}} = Previews.delete_preview(preview)
      assert_raise Ecto.NoResultsError, fn -> Previews.get_preview!(preview.id) end
    end

    test "change_preview/1 returns a preview changeset" do
      preview = preview_fixture()
      assert %Ecto.Changeset{} = Previews.change_preview(preview)
    end
  end

  describe "preview_contexts" do
    alias RiddlerAdmin.Previews.PreviewContext

    @valid_attrs %{data: %{}}
    @update_attrs %{data: %{}}
    @invalid_attrs %{data: nil}

    def preview_context_fixture(attrs \\ %{}) do
      {:ok, preview_context} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Previews.create_preview_context()

      preview_context
    end

    test "list_preview_contexts/0 returns all preview_contexts" do
      preview_context = preview_context_fixture()
      assert Previews.list_preview_contexts() == [preview_context]
    end

    test "get_preview_context!/1 returns the preview_context with given id" do
      preview_context = preview_context_fixture()
      assert Previews.get_preview_context!(preview_context.id) == preview_context
    end

    test "create_preview_context/1 with valid data creates a preview_context" do
      assert {:ok, %PreviewContext{} = preview_context} = Previews.create_preview_context(@valid_attrs)
      assert preview_context.data == %{}
    end

    test "create_preview_context/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Previews.create_preview_context(@invalid_attrs)
    end

    test "update_preview_context/2 with valid data updates the preview_context" do
      preview_context = preview_context_fixture()
      assert {:ok, %PreviewContext{} = preview_context} = Previews.update_preview_context(preview_context, @update_attrs)
      assert preview_context.data == %{}
    end

    test "update_preview_context/2 with invalid data returns error changeset" do
      preview_context = preview_context_fixture()
      assert {:error, %Ecto.Changeset{}} = Previews.update_preview_context(preview_context, @invalid_attrs)
      assert preview_context == Previews.get_preview_context!(preview_context.id)
    end

    test "delete_preview_context/1 deletes the preview_context" do
      preview_context = preview_context_fixture()
      assert {:ok, %PreviewContext{}} = Previews.delete_preview_context(preview_context)
      assert_raise Ecto.NoResultsError, fn -> Previews.get_preview_context!(preview_context.id) end
    end

    test "change_preview_context/1 returns a preview_context changeset" do
      preview_context = preview_context_fixture()
      assert %Ecto.Changeset{} = Previews.change_preview_context(preview_context)
    end
  end
end
