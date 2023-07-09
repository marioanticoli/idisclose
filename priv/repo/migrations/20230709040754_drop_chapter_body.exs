defmodule Idisclose.Repo.Migrations.DropChapterBody do
  use Ecto.Migration

  def change do
    alter table(:chapters) do
      remove :body
    end
  end
end
