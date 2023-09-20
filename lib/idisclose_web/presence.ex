defmodule IdiscloseWeb.Presence do
  @moduledoc """
  User presence module
  """
  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: Idisclose.PubSub

  # def init(_opts) do
  # {:ok, %{}}
  # end

  # def handle_metas(topic, %{joins: joins, leaves: leaves}, _presences, state) do
  ## fetch existing presence information for the joined users and broadcast the
  ## event to all subscribers
  # joins = Map.keys(joins)
  # leaves = Map.keys(leaves)
  # Phoenix.PubSub.broadcast(Idisclose.PubSub, topic, %{joins: joins, leaves: leaves})

  # {:ok, state}
  # end
end
