defmodule Idisclose.Documents.Chapter do
  use Ecto.Schema
  import Ecto.Changeset

  alias Idisclose.Documents.{Document, Section}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chapters" do
    field :title, :string
    field :order, :integer

    belongs_to :document, Document
    belongs_to :section, Section

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = chapter \\ %__MODULE__{}, attrs) do
    required_fields = [:title, :order, :document_id, :section_id]

    chapter
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> unique_constraint([:document_id, :section_id])
  end
end
