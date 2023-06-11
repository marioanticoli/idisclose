defmodule Idisclose.DocumentsTest do
  use Idisclose.DataCase

  alias Idisclose.Documents

  describe "templates" do
    alias Idisclose.Documents.Template

    import Idisclose.DocumentsFixtures

    @invalid_attrs %{description: nil, name: nil}

    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert Documents.list_templates() == [template]
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
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
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.update_template(template, @invalid_attrs)
      assert template == Documents.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Documents.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_template!(template.id) end
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
      update_attrs = %{body: "some updated body", description: "some updated description", title: "some updated title"}

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
end