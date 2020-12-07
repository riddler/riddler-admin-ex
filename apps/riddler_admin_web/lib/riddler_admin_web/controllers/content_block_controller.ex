defmodule RiddlerAdminWeb.ContentBlockController do
  use RiddlerAdminWeb, :controller

  alias RiddlerAdmin.ContentBlocks
  alias RiddlerAdmin.ContentBlocks.ContentBlock

  def index(conn, %{"workspace_id" => workspace_id}) do
    content_blocks = ContentBlocks.list_workspace_content_blocks(workspace_id)
    render(conn, "index.html", content_blocks: content_blocks, workspace_id: workspace_id)
  end

  def new(conn, %{"workspace_id" => workspace_id}) do
    changeset = ContentBlocks.change_content_block(%ContentBlock{})
    render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
  end

  def create(conn, %{"content_block" => content_block_params, "workspace_id" => workspace_id}) do
    case ContentBlocks.create_content_block(content_block_params, workspace_id) do
      {:ok, content_block} ->
        conn
        |> put_flash(:info, "ContentBlock created successfully.")
        |> redirect(
          to: Routes.workspace_content_block_path(conn, :show, workspace_id, content_block)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, workspace_id: workspace_id)
    end
  end

  def show(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    content_block = ContentBlocks.get_content_block!(id)
    render(conn, "show.html", content_block: content_block, workspace_id: workspace_id)
  end

  def edit(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    content_block = ContentBlocks.get_content_block!(id)
    changeset = ContentBlocks.change_content_block(content_block)
                |> IO.inspect()

    render(conn, "edit.html",
      content_block: content_block,
      changeset: changeset,
      workspace_id: workspace_id
    )
  end

  def update(conn, %{
        "id" => id,
        "content_block" => content_block_params,
        "workspace_id" => workspace_id
      }) do
    content_block = ContentBlocks.get_content_block!(id)

    case ContentBlocks.update_content_block(content_block, content_block_params) do
      {:ok, content_block} ->
        conn
        |> put_flash(:info, "ContentBlock updated successfully.")
        |> redirect(
          to: Routes.workspace_content_block_path(conn, :show, workspace_id, content_block)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          content_block: content_block,
          changeset: changeset,
          workspace_id: workspace_id
        )
    end
  end

  def delete(conn, %{"id" => id, "workspace_id" => workspace_id}) do
    content_block = ContentBlocks.get_content_block!(id)
    {:ok, _content_block} = ContentBlocks.delete_content_block(content_block)

    conn
    |> put_flash(:info, "ContentBlock deleted successfully.")
    |> redirect(to: Routes.workspace_content_block_path(conn, :index, workspace_id))
  end
end
