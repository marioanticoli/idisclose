defmodule IdiscloseWeb.RoomChannel do
  @moduledoc """
  Module to define channels to connect via websocket
  """
  use Phoenix.Channel

  alias IdiscloseWeb.Presence

  def join("room:lobby", _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def join("room:" <> user, _params, %{assigns: %{user: user}} = socket) do
    {:ok, socket}
  end

  def handle_in("broadcast_msg", %{"body" => body}, socket) do
    broadcast!(socket, "broadcast_msg", %{body: body, user: socket.assigns.user})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
