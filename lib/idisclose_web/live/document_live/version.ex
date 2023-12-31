defmodule IdiscloseWeb.DocumentLive.Version do
  use IdiscloseWeb, :live_view

  alias Idisclose.Documents
  alias Idisclose.PieceTableFacade.Impl, as: Facade

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @diff_template %{
    ins: ~s|<span class="bg-green-400">~s</span>|,
    del: ~s|<span class="bg-red-400">~s</span>|,
    edit: ~s|<span class="bg-blue-400">~s</span>|
  }

  # TODO: protect action
  @impl true
  def handle_params(%{"id" => document_id, "chapter_id" => chapter_id}, _, socket) do
    page_title = "Compare versions"
    chapter = Documents.get_chapter!(chapter_id)

    socket =
      case Facade.load(document_id, chapter_id) do
        {:ok, table} ->
          diff = PieceTable.get_text!(table)

          socket
          |> assign(:table, table)
          |> assign(:text, diff)

        _ ->
          put_flash(socket, :error, "There is no saved version to compare")
      end
      |> assign(:page_title, page_title)
      |> assign(:chapter, chapter)

    {:noreply, socket}
  end

  @impl true
  def handle_event(event, _params, socket) when event in ~w(next prev) do
    {table, diff} =
      event |> String.to_atom() |> Facade.diff_string(socket.assigns.table, @diff_template)

    diff = IO.iodata_to_binary(diff)

    socket =
      socket
      |> assign(:table, table)
      |> assign(:text, diff)

    {:noreply, socket}
  end

  def handle_event("select", _, socket) do
    # chapter = socket.assigns.chapter

    # socket.assigns.table
    ## remove any subsequent change
    # |> Map.put(:to_apply, [])
    # |> PieceTable.save(chapter.document_id, chapter.id)

    {:noreply, socket}
  end
end
