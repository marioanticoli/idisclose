defmodule Idisclose.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Idisclose.Documents` context.
  """

  @doc """
  Generate a template.
  """
  def template_fixture(attrs \\ %{}) do
    {:ok, template} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Idisclose.Documents.create_template()

    template
  end

  @doc """
  Generate a section.
  """
  def section_fixture(attrs \\ %{}) do
    {:ok, section} =
      attrs
      |> Enum.into(%{
        body: "some body",
        description: "some description",
        title: "some title"
      })
      |> Idisclose.Documents.create_section()

    section
  end

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    template = template_fixture()

    {:ok, document} =
      attrs
      |> Enum.into(%{
        deadline: ~D[2023-06-12],
        title: "some title",
        template_id: template.id
      })
      |> Idisclose.Documents.create_document()

    document
  end

  @doc """
  Generate a chapter.
  """
  def chapter_fixture(attrs \\ %{}) do
    section = section_fixture()
    document = document_fixture()

    {:ok, chapter} =
      attrs
      |> Enum.into(%{
        title: "some title",
        order: 42,
        section_id: section.id,
        document_id: document.id
      })
      |> Idisclose.Documents.create_chapter()

    chapter
  end

  @doc """
  Generate an association between section and template
  """
  def section_template_fixture(attrs \\ %{}) do
    section = section_fixture()
    template = template_fixture()

    {:ok, section_template} =
      attrs
      |> Enum.into(%{
        template_id: template.id,
        section_id: section.id,
        order: 0
      })
      |> Idisclose.Documents.create_section_template()

    section_template
  end
end
