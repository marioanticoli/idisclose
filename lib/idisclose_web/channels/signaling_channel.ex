defmodule IdiscloseWeb.SignalingChannel do
  @moduledoc """
  Channel module to comply with ICE requirements
  """
  use IdiscloseWeb, :channel

  alias IdiscloseWeb.Presence

  @impl true
  def join("signaling:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  # Handles the offer message.
  @impl true
  def handle_in("offer", payload, socket) do
    broadcast(socket, "offer", payload)
    {:noreply, socket}
  end

  # Handles the answer message.
  @impl true
  def handle_in("answer", payload, socket) do
    broadcast(socket, "answer", payload)
    {:noreply, socket}
  end

  # Handles the ICE candidate message.
  @impl true
  def handle_in("ice_candidate", payload, socket) do
    broadcast(socket, "ice_candidate", payload)
    {:noreply, socket}
  end

  # Catch-all clause
  @impl true
  def handle_in(_, _payload, socket) do
    {:noreply, socket}
  end

  # Generic message receiver
  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
