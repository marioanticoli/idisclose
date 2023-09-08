defmodule IdiscloseWeb.DocumentLive.Index do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [to_action: 1, authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Documents
  alias Idisclose.Documents.{Document, Template}

  @impl true
  def mount(_params, _session, socket) do
    {documents, templates} =
      if authorized?(socket, Document, :index) and authorized?(socket, Template, :index) do
        documents = Documents.list_documents()
        templates = Documents.list_templates([]) |> Enum.map(&{&1.name, &1.id})
        {documents, templates}
      else
        {[], []}
      end

    socket =
      socket
      |> stream(:documents, documents)
      # TODO: check if to use stream
      |> assign(:templates, templates)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    action = to_action(socket.assigns.live_action)

    socket =
      if authorized?(socket, Document, action) do
        apply_action(socket, socket.assigns.live_action, params)
      else
        put_error(socket, action)
      end

    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Document")
    |> assign(:document, Documents.get_document!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Document")
    |> assign(:document, %Document{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Documents")
    |> assign(:document, nil)
  end

  @impl true
  def handle_info({IdiscloseWeb.DocumentLive.FormComponent, {:saved, document}}, socket) do
    socket =
      if authorized?(socket, document, :create) do
        stream_insert(socket, :documents, document)
      else
        put_error(socket, :create)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket =
      if authorized?(socket, Document, :delete) do
        {:ok, document} = id |> Documents.get_document!() |> Documents.delete_document()
        stream_delete(socket, :documents, document)
      else
        put_error(socket, :delete)
      end

    {:noreply, socket}
  end

  def handle_event("archive", %{"id" => id}, socket) do
    socket =
      if authorized?(socket, Document, :archive) do
        {:ok, document} =
          id |> Documents.get_document!() |> Documents.update_document(%{archived?: true})

        stream_delete(socket, :documents, document)
      else
        put_error(socket, :archive)
      end

    {:noreply, socket}
  end
end
