defmodule IdiscloseWeb.Presence do
  @moduledoc """
  User presence module
  """
  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: Idisclose.PubSub
end
