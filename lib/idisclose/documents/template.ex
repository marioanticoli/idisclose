defmodule Idisclose.Documents.Template do
  @moduledoc """
  Handles create/update templates
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Idisclose.Documents.{Section, SectionTemplate}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "templates" do
    field(:description, :string)
    field(:name, :string)

    # establish an n-to-m relationship through sections_templates table
    many_to_many(:sections, Section, join_through: SectionTemplate, on_replace: :delete)

    timestamps()
  end

  @doc false
  # Pattern match variable template to be a struct Idisclose.Documents.Template, if it's not passed create an empty one
  def changeset(%__MODULE__{} = template \\ %__MODULE__{}, attrs) do
    required_fields = [:name, :description]

    template
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
