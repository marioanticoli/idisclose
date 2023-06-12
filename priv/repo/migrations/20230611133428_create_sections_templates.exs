defmodule Idisclose.Repo.Migrations.CreateSectionsTemplates do
  use Ecto.Migration

  def change do
    create table(:sections_templates, primary_key: false) do
      add :order, :integer

      add :section_id,
          references(:sections, on_delete: :delete_all, type: :binary_id, primary_key: true)

      add :template_id,
          references(:templates, on_delete: :delete_all, type: :binary_id, primary_key: true)

      timestamps()
    end

    create index(:sections_templates, [:order])
    create index(:sections_templates, [:section_id])
    create index(:sections_templates, [:template_id])
    # don't allow duplicated order values for a given template
    create unique_index(:sections_templates, [:order, :template_id])
  end
end
