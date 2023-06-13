defmodule IdiscloseWeb.DocumentLive.Editor do
  use IdiscloseWeb, :live_view

  alias Idisclose.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"chapter_id" => chapter_id}, _, socket) do
    page_title = "Edit Chapter"
    chapter = Documents.get_chapter!(chapter_id)
    form = chapter |> Documents.change_chapter() |> to_form()

    socket =
      socket
      |> assign(:page_title, page_title)
      |> assign(:chapter, chapter)
      |> assign(:form, form)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"chapter" => params}, socket) do
    socket =
      case Documents.update_chapter(socket.assigns.chapter, params) do
        {:ok, _} -> socket
        {:error, _} -> put_flash(socket, :error, "Couldn't save the file")
      end

    {:noreply, socket}
  end
end
