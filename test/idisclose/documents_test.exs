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
end
