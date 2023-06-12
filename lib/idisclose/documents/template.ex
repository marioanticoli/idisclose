defmodule Idisclose.Documents.Template do
  use Ecto.Schema
  import Ecto.Changeset

  alias Idisclose.Documents.Section

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "templates" do
    field(:description, :string)
    field(:name, :string)

    # establish an n-to-m relationship through sections_templates table
    many_to_many(:sections, Section, join_through: "sections_templates", on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
