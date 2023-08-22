defmodule Idisclose.Documents.Section do
  @moduledoc """
  Handles create/update sections 
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Idisclose.Documents.{SectionTemplate, Template}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sections" do
    field :body, :string
    field :description, :string
    field :title, :string

    field :order, :integer, virtual: true

    # establish an n-to-m relationship through sections_templates table
    many_to_many :templates, Template, join_through: SectionTemplate, on_replace: :delete

    timestamps()
  end

  @doc false
  # Pattern match variable section to be a struct Idisclose.Documents.Section, if it's not passed create an empty one
  def changeset(%__MODULE__{} = section \\ %__MODULE__{}, attrs) do
    required_fields = [:title, :body, :description]

    section
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
  end
end
