defmodule IdiscloseWeb.DocumentLive.Show do
  use IdiscloseWeb, :live_view

  alias Idisclose.Documents

  # This is a module attribute, it's used to define constants in the code
  @generated_docs_path "documents/generated"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    page_title = page_title(socket.assigns.live_action)
    document = Documents.get_document!(id)
    templates = Documents.list_templates([]) |> Enum.map(&{&1.name, &1.id})

    socket =
      socket
      |> assign(:page_title, page_title)
      |> assign(:document, document)
      |> assign(:templates, templates)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Document"
  defp page_title(:edit), do: "Edit Document"

  @impl true
  def handle_event("create_stub", _params, socket) do
    document = socket.assigns.document

    document
    |> Documents.create_document_chapters()
    |> handle_generate_response(document.id, socket)
  end

  def handle_event("generate_document", _params, socket) do
    document = socket.assigns.document
    filename = "#{document.title}.pdf"

    generate_pdf(document.chapters, filename)

    {:noreply, socket}
  end

  defp handle_generate_response({:error, _, _, _}, _id, socket) do
    socket =
      socket
      |> put_flash(:error, "Error generating the document")

    {:noreply, socket}
  end

  defp handle_generate_response({:ok, _}, id, socket) do
    document = Documents.get_document!(id)

    socket =
      socket
      |> assign(:document, document)
      |> put_flash(:info, "Document generated successfully")

    {:noreply, socket}
  end

  defp generate_pdf(chapters, filename) do
    Enum.flat_map(chapters, fn chapter ->
      [wrap_html(chapter.title, "h1"), chapter.body]
    end)
    |> IO.iodata_to_binary()
    |> PdfGenerator.generate_binary()
    |> write_pdf(filename)
  end

  defp write_pdf({:ok, content}, filename) do
    ["./priv/static", @generated_docs_path, filename]
    |> Path.join()
    |> Path.expand()
    |> File.write(content)
  end

  defp wrap_html(content, tag), do: "<#{tag}>#{content}</#{tag}>"
end
