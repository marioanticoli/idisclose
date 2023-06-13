defmodule Idisclose.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :deadline, :date
      add :template_id, references(:templates, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:documents, [:template_id])
  end
end
