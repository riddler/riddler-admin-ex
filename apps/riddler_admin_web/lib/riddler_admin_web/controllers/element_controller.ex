defmodule RiddlerAdminWeb.ElementController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.Elements
  alias RiddlerAdmin.Elements.Element

  def index(conn, %{"workspace_id" => workspace_id, "content_block_id" => content_block_id}) do
    elements = Elements.list_content_block_elements(content_block_id)

    render(conn, "index.html",
      elements: elements,
      workspace_id: workspace_id,
      content_block_id: content_block_id
    )
  end

  def new(conn, %{"workspace_id" => workspace_id, "content_block_id" => content_block_id}) do
    changeset = Elements.change_element(%Element{})

    render(conn, "new.html",
      changeset: changeset,
      workspace_id: workspace_id,
      content_block_id: content_block_id
    )
  end

  def create(conn, %{
        "element" => element_params,
        "workspace_id" => workspace_id,
        "content_block_id" => content_block_id
      }) do
    case Elements.create_element(element_params, content_block_id) do
      {:ok, element} ->
        conn
        |> put_flash(:info, "Element created successfully.")
        |> redirect(
          to:
            Routes.workspace_content_block_element_path(
              conn,
              :show,
              workspace_id,
              content_block_id,
              element
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html",
          changeset: changeset,
          workspace_id: workspace_id,
          content_block_id: content_block_id
        )
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id, "content_block_id" => content_block_id}) do
    element = Elements.get_element!(id)

    render(conn, "show.html",
      element: element,
      workspace_id: workspace_id,
      content_block_id: content_block_id
    )
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id, "content_block_id" => content_block_id}) do
    element = Elements.get_element!(id)
    changeset = Elements.change_element(element)

    render(conn, "edit.html",
      element: element,
      changeset: changeset,
      workspace_id: workspace_id,
      content_block_id: content_block_id
    )
  end

  def update(conn, %{
        "id" => id,
        "element" => element_params,
        "workspace_id" => workspace_id,
        "content_block_id" => content_block_id
      }) do
    element = Elements.get_element!(id)

    case Elements.update_element(element, element_params) do
      {:ok, element} ->
        conn
        |> put_flash(:info, "Element updated successfully.")
        |> redirect(
          to:
            Routes.workspace_content_block_element_path(
              conn,
              :show,
              workspace_id,
              content_block_id,
              element
            )
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          element: element,
          changeset: changeset,
          workspace_id: workspace_id,
          content_block_id: content_block_id
        )
    end
  end

  def delete(conn, %{
        "id" => id,
        "workspace_id" => workspace_id,
        "content_block_id" => content_block_id
      }) do
    element = Elements.get_element!(id)
    {:ok, _element} = Elements.delete_element(element)

    conn
    |> put_flash(:info, "Element deleted successfully.")
    |> redirect(
      to: Routes.workspace_content_block_element_path(conn, :index, workspace_id, content_block_id)
    )
  end
end
