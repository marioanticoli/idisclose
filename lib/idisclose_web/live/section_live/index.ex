defmodule IdiscloseWeb.SectionLive.Index do
  use IdiscloseWeb, :live_view

  alias Idisclose.Documents
  alias Idisclose.Documents.Section

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :sections, Documents.list_sections())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Section")
    |> assign(:section, Documents.get_section!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Section")
    |> assign(:section, %Section{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sections")
    |> assign(:section, nil)
  end

  @impl true
  def handle_info({IdiscloseWeb.SectionLive.FormComponent, {:saved, section}}, socket) do
    {:noreply, stream_insert(socket, :sections, section)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    section = Documents.get_section!(id)
    {:ok, _} = Documents.delete_section(section)

    {:noreply, stream_delete(socket, :sections, section)}
  end
end
