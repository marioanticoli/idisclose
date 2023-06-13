defmodule Idisclose.Repo.Migrations.CreateChapters do
  use Ecto.Migration

  def change do
    create table(:chapters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :body, :text
      add :order, :integer
      add :document_id, references(:documents, on_delete: :nothing, type: :binary_id)
      add :section_id, references(:sections, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:chapters, [:document_id])
    create index(:chapters, [:section_id])
    create unique_index(:chapters, [:document_id, :section_id])
  end
end
