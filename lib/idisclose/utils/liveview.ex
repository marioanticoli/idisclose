defmodule Idisclose.Utils.Liveview do
  @moduledoc """
  Utilities for working with liveviews
  """
  import Phoenix.LiveView, only: [put_flash: 3]

  def put_error(socket, action) do
    put_flash(socket, :error, "Unauthorized action: #{action}")
  end
end
