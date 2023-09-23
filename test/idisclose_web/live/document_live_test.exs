defmodule IdiscloseWeb.DocumentLiveTest do
  use IdiscloseWeb.ConnCase

  import Phoenix.LiveViewTest
  import Idisclose.DocumentsFixtures

  @create_attrs %{deadline: "2023-06-12", title: "some title"}
  @update_attrs %{deadline: "2023-06-13", title: "some updated title"}
  @invalid_attrs %{deadline: nil, title: nil}

  defp create_document(_) do
    document = document_fixture()
    chapter = chapter_fixture(%{document_id: document.id})
    %{chapter: chapter, document: document}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_document]

    test "lists all documents", %{conn: conn, document: document} do
      {:ok, _index_live, html} = live(conn, ~p"/documents")

      assert html =~ "Listing Documents"
      assert html =~ document.title
    end

    test "saves new document", %{conn: conn, document: _document} do
      {:ok, index_live, _html} = live(conn, ~p"/documents")

      assert index_live |> element("a", "New Document") |> render_click() =~
               "New Document"

      assert_patch(index_live, ~p"/documents/new")

      assert index_live
             |> form("#document-form", document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#document-form", document: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/documents")

      # html = render(index_live)
      # assert html =~ "Document created successfully"
      # assert html =~ "some title"
    end

    test "updates document in listing", %{conn: conn, document: document} do
      {:ok, index_live, _html} = live(conn, ~p"/documents")

      assert index_live |> element("#documents-#{document.id} a", "Edit") |> render_click() =~
               "Edit Document"

      assert_patch(index_live, ~p"/documents/#{document}/edit")

      assert index_live
             |> form("#document-form", document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#document-form", document: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/documents")

      html = render(index_live)
      assert html =~ "Document updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes document in listing", %{conn: conn, document: document} do
      {:ok, index_live, _html} = live(conn, ~p"/documents")

      assert index_live |> element("#documents-#{document.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#documents-#{document.id}")
    end

    test "load chapter", %{conn: conn, chapter: chapter} do
      content = File.read!("test/support/fixtures/support_files/piece_table")

      Mox.expect(Idisclose.FileStorage.Mock, :file_read, 2, fn _, _ ->
        {:ok, content}
      end)

      {:ok, _index_live, html} =
        live(conn, ~p"/documents/#{chapter.document_id}/chapter/#{chapter.id}")

      assert html =~ "Save Document"
    end

    test "fail to load chapter doesn't crash", %{conn: conn, chapter: chapter} do
      Mox.expect(Idisclose.FileStorage.Mock, :file_read, 2, fn _, _ ->
        {:error, :enoent}
      end)

      {:ok, _index_live, html} =
        live(conn, ~p"/documents/#{chapter.document_id}/chapter/#{chapter.id}")

      assert html =~ "Save Document"
    end

    test "compare changes in chapter", %{conn: conn, chapter: chapter} do
      content = File.read!("test/support/fixtures/support_files/piece_table")

      Mox.expect(Idisclose.FileStorage.Mock, :file_read, 2, fn _, _ ->
        {:ok, content}
      end)

      {:ok, _index_live, html} =
        live(conn, ~p"/documents/#{chapter.document_id}/chapter/#{chapter.id}/compare")

      assert html =~ "Select this version"
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_document]

    test "displays document", %{conn: conn, document: document} do
      {:ok, _show_live, html} = live(conn, ~p"/documents/#{document}")

      assert html =~ "Show Document"
      assert html =~ document.title
    end

    test "updates document within modal", %{conn: conn, document: document} do
      {:ok, show_live, _html} = live(conn, ~p"/documents/#{document}")

      assert show_live |> element("a", "Edit document") |> render_click() =~
               "Edit Document"

      assert_patch(show_live, ~p"/documents/#{document}/show/edit")

      assert show_live
             |> form("#document-form", document: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#document-form", document: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/documents/#{document}")

      html = render(show_live)
      assert html =~ "Document updated successfully"
      assert html =~ "some updated title"
    end
  end

  describe "not logged" do
    setup [:create_document]

    test "displays document", %{conn: conn, document: document} do
      assert {:error, {:redirect, %{to: "/users/log_in"}}} =
               live(conn, ~p"/documents/#{document}")
    end

    test "lists all documents", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, ~p"/documents")
    end
  end
end
