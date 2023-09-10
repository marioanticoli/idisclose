defmodule IdiscloseWeb.SignalingChannel do
  @moduledoc """
  Channel module to comply with ICE requirements
  """
  use IdiscloseWeb, :channel

  @impl true
  def join("signaling:lobby", _payload, socket) do
    # peer_id = payload["peer_id"]
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
end
