defmodule Idisclose.Documents.Section do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sections" do
    field :body, :string
    field :description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :body, :description])
    |> validate_required([:title, :body, :description])
  end
end
