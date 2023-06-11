defmodule Idisclose.Documents.Template do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "templates" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(template, attrs) do
    template
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
