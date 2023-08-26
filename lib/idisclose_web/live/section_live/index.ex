defmodule IdiscloseWeb.SectionLive.Index do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [to_action: 1, authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Documents
  alias Idisclose.Documents.Section

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :sections, list_sections(socket))}
  end

  defp list_sections(socket) do
    if authorized?(socket, Section, :index) do
      Documents.list_sections()
    else
      []
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    action = to_action(socket.assigns.live_action)

    socket =
      if authorized?(socket, Section, action) do
        apply_action(socket, socket.assigns.live_action, params)
      else
        put_error(socket, action)
      end

    {:noreply, socket}
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
    socket =
      if authorized?(socket, section, :create) do
        stream_insert(socket, :sections, section)
      else
        put_error(socket, :create)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket =
      if authorized?(socket, Section, :delete) do
        {:ok, section} = id |> Documents.get_section!() |> Documents.delete_section()
        stream_delete(socket, :sections, section)
      else
        put_error(socket, :delete)
      end

    {:noreply, socket}
  end
end
