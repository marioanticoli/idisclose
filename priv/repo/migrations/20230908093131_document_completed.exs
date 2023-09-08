defmodule Idisclose.Repo.Migrations.DocumentCompleted do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :archived?, :boolean, default: false
    end
  end
end
