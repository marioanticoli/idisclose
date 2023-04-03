defmodule Idisclose.ReleaseTasks do
  def migrate do
    {:ok, _, _} = Ecto.Migrator.with_repo(Idisclose.Repo, &Ecto.Migrator.run(&1, :up, all: true))
  end

  # def post_deploy_migrations do
  # {:ok, _, _} =
  # Ecto.Migrator.with_repo(
  # Idisclose.Repo,
  # &Ecto.Migrator.run(&1, "priv/repo/post_deploy_migrations", :up, all: true)
  # )
  # end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  # def post_deploy_migrations_rollback(version) do
  # {:ok, _, _} =
  # Ecto.Migrator.with_repo(
  # Idisclose.Repo,
  # &Ecto.Migrator.run(&1, "priv/repo/post_deploy_migrations", :down, to: version)
  # )
  # end
end
