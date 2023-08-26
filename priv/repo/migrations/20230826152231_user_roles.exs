defmodule Idisclose.Repo.Migrations.UserRoles do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :text, null: false, default: "invitee"
    end
  end
end
