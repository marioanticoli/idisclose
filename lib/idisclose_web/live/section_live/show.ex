defmodule IdiscloseWeb.SectionLive.Show do
  use IdiscloseWeb, :live_view

  alias Idisclose.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:section, Documents.get_section!(id))}
  end

  defp page_title(:show), do: "Show Section"
  defp page_title(:edit), do: "Edit Section"
end
