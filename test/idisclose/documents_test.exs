defmodule Idisclose.DocumentsTest do
  use Idisclose.DataCase

  alias Idisclose.Documents

  describe "templates" do
    alias Idisclose.Documents.Template

    import Idisclose.DocumentsFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_templates/0 returns all templates" do
      template = template_fixture() |> Repo.preload([:sections])
      assert Documents.list_templates() == [template]
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture() |> Repo.preload([:sections])
      assert Documents.get_template!(template.id) == template
    end

    test "create_template/1 with valid data creates a template" do
      valid_attrs = %{description: "some description", name: "some name"}

      assert {:ok, %Template{} = template} = Documents.create_template(valid_attrs)
      assert template.description == "some description"
      assert template.name == "some name"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name"}

      assert {:ok, %Template{} = template} = Documents.update_template(template, update_attrs)
      assert template.description == "some updated description"
      assert template.name == "some updated name"
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture() |> Repo.preload([:sections])
      assert {:error, %Ecto.Changeset{}} = Documents.update_template(template, @invalid_attrs)
      assert template == Documents.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Documents.delete_template(template)
      refute Documents.get_template(template.id)
    end

    test "change_template/1 returns a template changeset" do
      template = template_fixture()
      assert %Ecto.Changeset{} = Documents.change_template(template)
    end
  end

  describe "sections" do
    alias Idisclose.Documents.Section

    import Idisclose.DocumentsFixtures

    @invalid_attrs %{body: nil, description: nil, title: nil}

    test "list_sections/0 returns all sections" do
      section = section_fixture()
      assert Documents.list_sections() == [section]
    end

    test "list_sections/1 not in list" do
      section1 = section_fixture()
      section2 = section_fixture()
      section3 = section_fixture()
      assert Documents.list_sections_not_associated([section1.id]) == [section2, section3]
    end

    test "get_section!/1 returns the section with given id" do
      section = section_fixture()
      assert Documents.get_section!(section.id) == section
    end

    test "create_section/1 with valid data creates a section" do
      valid_attrs = %{body: "some body", description: "some description", title: "some title"}

      assert {:ok, %Section{} = section} = Documents.create_section(valid_attrs)
      assert section.body == "some body"
      assert section.description == "some description"
      assert section.title == "some title"
    end

    test "create_section/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_section(@invalid_attrs)
    end

    test "update_section/2 with valid data updates the section" do
      section = section_fixture()

      update_attrs = %{
        body: "some updated body",
        description: "some updated description",
        title: "some updated title"
      }

      assert {:ok, %Section{} = section} = Documents.update_section(section, update_attrs)
      assert section.body == "some updated body"
      assert section.description == "some updated description"
      assert section.title == "some updated title"
    end

    test "update_section/2 with invalid data returns error changeset" do
      section = section_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_section(section, @invalid_attrs)
      assert section == Documents.get_section!(section.id)
    end

    test "delete_section/1 deletes the section" do
      section = section_fixture()
      assert {:ok, %Section{}} = Documents.delete_section(section)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_section!(section.id) end
    end

    test "change_section/1 returns a section changeset" do
      section = section_fixture()
      assert %Ecto.Changeset{} = Documents.change_section(section)
    end
  end

  describe "documents" do
    alias Idisclose.Documents.Document

    import Idisclose.DocumentsFixtures

    @invalid_attrs %{deadline: nil, title: nil}

    test "list_documents/0 returns all documents" do
      document = document_fixture() |> Repo.preload(:template)
      assert Documents.list_documents() == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture() |> Repo.preload([:chapters, [template: :sections]])
      assert Documents.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      template = template_fixture()
      valid_attrs = %{deadline: ~D[2023-06-12], title: "some title", template_id: template.id}

      assert {:ok, %Document{} = document} = Documents.create_document(valid_attrs)
      assert document.deadline == ~D[2023-06-12]
      assert document.title == "some title"
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      update_attrs = %{deadline: ~D[2023-06-13], title: "some updated title"}

      assert {:ok, %Document{} = document} = Documents.update_document(document, update_attrs)
      assert document.deadline == ~D[2023-06-13]
      assert document.title == "some updated title"
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture() |> Repo.preload([:chapters, [template: :sections]])
      assert {:error, %Ecto.Changeset{}} = Documents.update_document(document, @invalid_attrs)
      assert document == Documents.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Documents.delete_document(document)
      refute Documents.get_document!(document.id)
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end

  describe "chapters" do
    alias Idisclose.Documents.Chapter

    import Idisclose.DocumentsFixtures

    @invalid_attrs %{body: nil, order: nil}

    test "list_chapters/0 returns all chapters" do
      chapter = chapter_fixture()
      assert Documents.list_chapters() == [chapter]
    end

    test "get_chapter!/1 returns the chapter with given id" do
      chapter = chapter_fixture()
      assert Documents.get_chapter!(chapter.id) == chapter
    end

    test "create_chapter/1 with valid data creates a chapter" do
      document = document_fixture()
      section = section_fixture()

      valid_attrs = %{
        title: "some title",
        order: 42,
        document_id: document.id,
        section_id: section.id
      }

      assert {:ok, %Chapter{} = chapter} = Documents.create_chapter(valid_attrs)
      assert chapter.title == "some title"
      assert chapter.order == 42
    end

    test "create_chapter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Documents.create_chapter(@invalid_attrs)
    end

    test "update_chapter/2 with valid data updates the chapter" do
      chapter = chapter_fixture()
      update_attrs = %{title: "some updated title", order: 43}

      assert {:ok, %Chapter{} = chapter} = Documents.update_chapter(chapter, update_attrs)
      assert chapter.title == "some updated title"
      assert chapter.order == 43
    end

    test "update_chapter/2 with invalid data returns error changeset" do
      chapter = chapter_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_chapter(chapter, @invalid_attrs)
      assert chapter == Documents.get_chapter!(chapter.id)
    end

    test "delete_chapter/1 deletes the chapter" do
      chapter = chapter_fixture()
      assert {:ok, %Chapter{}} = Documents.delete_chapter(chapter)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_chapter!(chapter.id) end
    end

    test "change_chapter/1 returns a chapter changeset" do
      chapter = chapter_fixture()
      assert %Ecto.Changeset{} = Documents.change_chapter(chapter)
    end
  end
end
