defmodule IdiscloseWeb.DocumentLive.Editor do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Documents
  alias Idisclose.PieceTableFacade.Impl, as: PieceTable
  alias Idisclose.Documents.Chapter

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # TODO: protect action
  @impl true
  def handle_params(%{"chapter_id" => chapter_id}, _, socket) do
    page_title = "Edit Chapter"

    socket =
      if authorized?(socket, Chapter, :edit) do
        chapter = Documents.get_chapter!(chapter_id)

        # if it finds a document loads it, otherwise use the default from the section
        table =
          case PieceTable.load(chapter.document_id, chapter_id) do
            {:ok, t} ->
              t

            _ ->
              section = Documents.get_section!(chapter.section_id)
              PieceTable.new!(section.body)
          end

        form = make_form(chapter, table)

        socket
        |> assign(:page_title, page_title)
        |> assign(:chapter, chapter)
        |> assign(:form, form)
        |> assign(:table, table)
      else
        put_error(socket, :edit)
      end

    {:noreply, socket}
  end

  defp make_form(chapter, table),
    do: chapter |> Documents.change_chapter(%{body: table.result}) |> to_form()

  @impl true
  def handle_event("save", %{"chapter" => params}, socket) do
    chapter = socket.assigns.chapter
    user = socket.assigns.current_user.email

    socket =
      if authorized?(socket, Chapter, :edit) do
        case update_piece_table(
               socket.assigns.table,
               params["body"],
               chapter.document_id,
               chapter.id,
               user
             ) do
          {:ok, table} ->
            assign(socket, :table, table)

          {:error, _} ->
            put_flash(socket, :error, "Couldn't save the file")
        end
      else
        put_error(socket, :edit)
      end

    {:noreply, socket}
  end

  def handle_event("compare", _params, socket) do
    chapter = socket.assigns.chapter
    table = socket.assigns.table
    user = socket.assigns.current_user.email

    case update_piece_table(table, table.result, chapter.document_id, chapter.id, user) do
      {:ok, _} ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/documents/#{chapter.document_id}/chapter/#{chapter.id}/compare"
         )}

      _ ->
        {:noreply, put_flash(socket, :error, "Couldn't save the file")}
    end
  end

  # the repeated body checks for equality, in which case no need to write the file
  # defp update_piece_table(%{result: body} = table, body, _, _), do: {:ok, table}

  defp update_piece_table(table, body, document_id, chapter_id, user) do
    with {:ok, t} <- PieceTable.diff(table, body, user) do
      PieceTable.save(t, document_id, chapter_id)
    end
  end
end
