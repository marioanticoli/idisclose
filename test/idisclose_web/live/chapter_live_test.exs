defmodule IdiscloseWeb.ChapterLiveTest do
  use IdiscloseWeb.ConnCase

  import Phoenix.LiveViewTest
  import Idisclose.DocumentsFixtures

  @create_attrs %{body: "some body", order: 42}
  @update_attrs %{body: "some updated body", order: 43}
  @invalid_attrs %{body: nil, order: nil}

  defp create_chapter(_) do
    chapter = chapter_fixture()
    %{chapter: chapter}
  end

  describe "Index" do
    setup [:create_chapter]

    test "lists all chapters", %{conn: conn, chapter: chapter} do
      {:ok, _index_live, html} = live(conn, ~p"/chapters")

      assert html =~ "Listing Chapters"
      assert html =~ chapter.body
    end

    test "saves new chapter", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/chapters")

      assert index_live |> element("a", "New Chapter") |> render_click() =~
               "New Chapter"

      assert_patch(index_live, ~p"/chapters/new")

      assert index_live
             |> form("#chapter-form", chapter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chapter-form", chapter: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chapters")

      html = render(index_live)
      assert html =~ "Chapter created successfully"
      assert html =~ "some body"
    end

    test "updates chapter in listing", %{conn: conn, chapter: chapter} do
      {:ok, index_live, _html} = live(conn, ~p"/chapters")

      assert index_live |> element("#chapters-#{chapter.id} a", "Edit") |> render_click() =~
               "Edit Chapter"

      assert_patch(index_live, ~p"/chapters/#{chapter}/edit")

      assert index_live
             |> form("#chapter-form", chapter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chapter-form", chapter: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chapters")

      html = render(index_live)
      assert html =~ "Chapter updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes chapter in listing", %{conn: conn, chapter: chapter} do
      {:ok, index_live, _html} = live(conn, ~p"/chapters")

      assert index_live |> element("#chapters-#{chapter.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chapters-#{chapter.id}")
    end
  end

  describe "Show" do
    setup [:create_chapter]

    test "displays chapter", %{conn: conn, chapter: chapter} do
      {:ok, _show_live, html} = live(conn, ~p"/chapters/#{chapter}")

      assert html =~ "Show Chapter"
      assert html =~ chapter.body
    end

    test "updates chapter within modal", %{conn: conn, chapter: chapter} do
      {:ok, show_live, _html} = live(conn, ~p"/chapters/#{chapter}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chapter"

      assert_patch(show_live, ~p"/chapters/#{chapter}/show/edit")

      assert show_live
             |> form("#chapter-form", chapter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#chapter-form", chapter: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/chapters/#{chapter}")

      html = render(show_live)
      assert html =~ "Chapter updated successfully"
      assert html =~ "some updated body"
    end
  end
end
