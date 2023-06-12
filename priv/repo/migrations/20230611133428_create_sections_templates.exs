defmodule Idisclose.Repo.Migrations.CreateSectionsTemplates do
  use Ecto.Migration

  def change do
    create table(:sections_templates, primary_key: false) do
      add :section_id,
          references(:sections, on_delete: :delete_all, type: :binary_id, primary_key: true)

      add :template_id,
          references(:templates, on_delete: :delete_all, type: :binary_id, primary_key: true)

      timestamps()
    end

    create index(:sections_templates, [:section_id])
    create index(:sections_templates, [:template_id])
  end
end
