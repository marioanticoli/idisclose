defmodule IdiscloseWeb.SectionLiveTest do
  use IdiscloseWeb.ConnCase

  import Phoenix.LiveViewTest
  import Idisclose.DocumentsFixtures

  @create_attrs %{body: "some body", description: "some description", title: "some title"}
  @update_attrs %{body: "some updated body", description: "some updated description", title: "some updated title"}
  @invalid_attrs %{body: nil, description: nil, title: nil}

  defp create_section(_) do
    section = section_fixture()
    %{section: section}
  end

  describe "Index" do
    setup [:create_section]

    test "lists all sections", %{conn: conn, section: section} do
      {:ok, _index_live, html} = live(conn, ~p"/sections")

      assert html =~ "Listing Sections"
      assert html =~ section.body
    end

    test "saves new section", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/sections")

      assert index_live |> element("a", "New Section") |> render_click() =~
               "New Section"

      assert_patch(index_live, ~p"/sections/new")

      assert index_live
             |> form("#section-form", section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#section-form", section: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/sections")

      html = render(index_live)
      assert html =~ "Section created successfully"
      assert html =~ "some body"
    end

    test "updates section in listing", %{conn: conn, section: section} do
      {:ok, index_live, _html} = live(conn, ~p"/sections")

      assert index_live |> element("#sections-#{section.id} a", "Edit") |> render_click() =~
               "Edit Section"

      assert_patch(index_live, ~p"/sections/#{section}/edit")

      assert index_live
             |> form("#section-form", section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#section-form", section: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/sections")

      html = render(index_live)
      assert html =~ "Section updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes section in listing", %{conn: conn, section: section} do
      {:ok, index_live, _html} = live(conn, ~p"/sections")

      assert index_live |> element("#sections-#{section.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sections-#{section.id}")
    end
  end

  describe "Show" do
    setup [:create_section]

    test "displays section", %{conn: conn, section: section} do
      {:ok, _show_live, html} = live(conn, ~p"/sections/#{section}")

      assert html =~ "Show Section"
      assert html =~ section.body
    end

    test "updates section within modal", %{conn: conn, section: section} do
      {:ok, show_live, _html} = live(conn, ~p"/sections/#{section}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Section"

      assert_patch(show_live, ~p"/sections/#{section}/show/edit")

      assert show_live
             |> form("#section-form", section: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#section-form", section: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/sections/#{section}")

      html = render(show_live)
      assert html =~ "Section updated successfully"
      assert html =~ "some updated body"
    end
  end
end
