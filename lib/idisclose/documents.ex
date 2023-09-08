defmodule Idisclose.Documents do
  @moduledoc """
  The Documents context.
  """

  # import query functions
  import Ecto.Query, only: [from: 2, where: 3, join: 4, limit: 2], warn: false

  alias Idisclose.Repo
  alias Idisclose.Documents.{Chapter, Document, Section, SectionTemplate, Template}

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates(preloads \\ [:sections]) do
    Template |> Repo.all() |> Repo.preload(preloads)
  end

  @doc """
  Gets a single template.

  Returns nil if the Template does not exist.

  ## Examples

      iex> get_template(123)
      %Template{}

      iex> get_template(456)
      nil

  """
  def get_template(id) do
    Template |> Repo.get(id) |> Repo.preload([:sections])

    # Queries are composable, it means I can build one bit by bit 

    # This would fetch all templates with preloaded sections
    # query_preload(Template, [:sections])
    # apply where to filter by ID
    # |> where([m], m.id == ^id)
    # limit to speed up the query
    # |> limit(1)
    # actually execute the query
    # |> Repo.one()
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id) do
    case get_template(id) do
      %Template{} = template -> template
      _ -> raise Ecto.NoResultsError
    end
  end

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{data: %Template{}}

  """
  def change_template(%Template{} = template, attrs \\ %{}) do
    Template.changeset(template, attrs)
  end

  @doc """
  Returns the list of sections.

  ## Examples

      iex> list_sections()
      [%Section{}, ...]

  """
  def list_sections do
    Repo.all(Section)
  end

  @doc """
  Returns the list of sections not associated to a given template.

  ## Examples

      iex> list_sections_not_associated(sectiond_ids)
      [%Section{}, ...]

  """
  def list_sections_not_associated(section_ids) when is_list(section_ids) do
    from(s in Section, where: s.id not in ^section_ids) |> Repo.all()
  end

  @doc """
  Gets a single section.

  Raises `Ecto.NoResultsError` if the Section does not exist.

  ## Examples

      iex> get_section!(123)
      %Section{}

      iex> get_section!(456)
      ** (Ecto.NoResultsError)

  """
  def get_section!(id), do: Repo.get!(Section, id)

  @doc """
  Creates a section.

  ## Examples

      iex> create_section(%{field: value})
      {:ok, %Section{}}

      iex> create_section(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_section(attrs \\ %{}) do
    %Section{}
    |> Section.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a section.

  ## Examples

      iex> update_section(section, %{field: new_value})
      {:ok, %Section{}}

      iex> update_section(section, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_section(%Section{} = section, attrs) do
    section
    |> Section.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a section.

  ## Examples

      iex> delete_section(section)
      {:ok, %Section{}}

      iex> delete_section(section)
      {:error, %Ecto.Changeset{}}

  """
  def delete_section(%Section{} = section) do
    Repo.delete(section)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking section changes.

  ## Examples

      iex> change_section(section)
      %Ecto.Changeset{data: %Section{}}

  """
  def change_section(%Section{} = section, attrs \\ %{}) do
    Section.changeset(section, attrs)
  end

  @doc """
  Creates a template.

  ## Examples

      iex> create_section_template(%{field: value})
      {:ok, %SectionTemplate{}}

      iex> create_section_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_section_template(attrs \\ %{}) do
    %SectionTemplate{}
    |> SectionTemplate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a section template.

  ## Examples

      iex> delete_section_template(section_template)
      {:ok, %SectionTemplate{}}

      iex> delete_section_template(section_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_section_template(section_id, template_id) do
    query =
      from(st in SectionTemplate,
        where: st.section_id == ^section_id,
        where: st.template_id == ^template_id
      )

    case Repo.delete_all(query) do
      {1, _} -> :ok
      _ -> :error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking section template changes.

  ## Examples

      iex> change_section_template(section_template)
      %Ecto.Changeset{data: %SectionTemplate{}}

  """
  def change_section_template(%SectionTemplate{} = section_template, attrs \\ %{}) do
    SectionTemplate.changeset(section_template, attrs)
  end

  # This private functions allows me to pass any schema and a list of desired preloads and returns a query
  # defp query_preload(module, associations) when is_list(associations) do
  # query =
  # from(m in module,
  ## preload loads the associations as if they were actual fields of the record
  # preload: ^associations,
  ## TODO: check if I can do something on the schema side
  # distinct: m
  # )

  ## reduce the associations into a single query applying a series of left join to ensures all is done in a single query
  # Enum.reduce(associations, query, &join(&2, :left, [q], a in assoc(q, ^&1)))
  # end

  @doc """
  Returns the list of documents.

  ## Examples

      iex> list_documents()
      [%Document{}, ...]

  """
  def list_documents(preloads \\ [:template], where \\ [archived?: false]) do
    from(d in Document, where: ^where)
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id) do
    from(d in Document,
      where: d.id == ^id,
      select: d,
      preload: [
        template: :sections,
        chapters: ^from(c in Chapter, order_by: [asc: c.order])
      ],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{data: %Document{}}

  """
  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end

  @doc """
  Returns the list of chapters.

  ## Examples

      iex> list_chapters()
      [%Chapter{}, ...]

  """
  def list_chapters do
    Repo.all(Chapter)
  end

  @doc """
  Gets a single chapter.

  Raises `Ecto.NoResultsError` if the Chapter does not exist.

  ## Examples

      iex> get_chapter!(123)
      %Chapter{}

      iex> get_chapter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chapter!(id), do: Repo.get!(Chapter, id)

  @doc """
  Creates a chapter.

  ## Examples

      iex> create_chapter(%{field: value})
      {:ok, %Chapter{}}

      iex> create_chapter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chapter(attrs \\ %{}) do
    %Chapter{}
    |> Chapter.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chapter.

  ## Examples

      iex> update_chapter(chapter, %{field: new_value})
      {:ok, %Chapter{}}

      iex> update_chapter(chapter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chapter(%Chapter{} = chapter, attrs) do
    chapter
    |> Chapter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chapter.

  ## Examples

      iex> delete_chapter(chapter)
      {:ok, %Chapter{}}

      iex> delete_chapter(chapter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chapter(%Chapter{} = chapter) do
    Repo.delete(chapter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chapter changes.

  ## Examples

      iex> change_chapter(chapter)
      %Ecto.Changeset{data: %Chapter{}}

  """
  def change_chapter(%Chapter{} = chapter, attrs \\ %{}) do
    Chapter.changeset(chapter, attrs)
  end

  def create_document_chapters(%Document{} = document) do
    section_ids = Enum.map(document.template.sections, & &1.id)

    sections =
      from(
        st in SectionTemplate,
        join: s in assoc(st, :section),
        where: s.id in ^section_ids,
        select: %{s | order: st.order}
      )
      |> Repo.all()

    Enum.reduce(sections, Ecto.Multi.new(), fn section, multi ->
      attrs = %{
        title: section.title,
        body: section.body,
        order: section.order,
        document_id: document.id,
        section_id: section.id
      }

      changeset = change_chapter(%Chapter{}, attrs)

      Ecto.Multi.insert(multi, section.id, changeset)
    end)
    |> Repo.transaction()
  end
end
