defmodule Idisclose.Documents.SectionTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  alias Idisclose.Documents.{Section, Template}

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "sections_templates" do
    field :order, :integer

    # establish relationships
    belongs_to :template, Template
    belongs_to :section, Section

    timestamps()
  end

  @doc false
  # Pattern match variable section_template to be a struct Idisclose.Documents.SectionTemplate, if it's not passed create an empty one
  def changeset(%__MODULE__{} = section_template \\ %__MODULE__{}, attrs) do
    required_fields = [:order, :section_id, :template_id]

    section_template
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> validate_number(:order, greater_than_or_equal_to: 0)
    |> unique_constraint([:order, :template_id])
  end
end
