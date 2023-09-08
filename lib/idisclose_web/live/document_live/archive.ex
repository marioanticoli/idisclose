defmodule IdiscloseWeb.DocumentLive.Archive do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Documents
  alias Idisclose.Documents.{Document, Template}

  @impl true
  def mount(_params, _session, socket) do
    {documents, templates} =
      if authorized?(socket, Document, :index) and authorized?(socket, Template, :index) do
        documents = Documents.list_documents([:template], archived?: true)
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
  def handle_event("unarchive", %{"id" => id}, socket) do
    socket =
      if authorized?(socket, Document, :unarchive) do
        {:ok, document} =
          id |> Documents.get_document!() |> Documents.update_document(%{archived?: false})

        stream_delete(socket, :documents, document)
      else
        put_error(socket, :unarchive)
      end

    {:noreply, socket}
  end
end
