defmodule Idisclose.Repo do
  use Ecto.Repo,
    otp_app: :idisclose,
    adapter: Ecto.Adapters.Postgres
end
