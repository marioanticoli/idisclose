defmodule Idisclose.Documents.Document do
  @moduledoc """
  Handles create/update documents
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Idisclose.Documents.{Chapter, Template}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "documents" do
    field(:deadline, :date)
    field(:title, :string)
    field(:archived?, :boolean, default: false)

    belongs_to(:template, Template)
    has_many(:chapters, Chapter, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = document \\ %__MODULE__{}, attrs) do
    required_fields = [:title, :deadline, :template_id]
    fields = [:archived? | required_fields]

    document
    |> cast(attrs, fields)
    |> validate_required(required_fields)
  end
end
