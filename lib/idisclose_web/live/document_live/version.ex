defmodule IdiscloseWeb.DocumentLive.Version do
  use IdiscloseWeb, :live_view

  alias Idisclose.Documents
  alias Idisclose.PieceTableFacade, as: PieceTable

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => document_id, "chapter_id" => chapter_id}, _, socket) do
    page_title = "Compare versions"
    chapter = Documents.get_chapter!(chapter_id)

    socket =
      case PieceTable.load(document_id, chapter_id) do
        {:ok, t} ->
          {table, diff} = build_diff(:prev, t)

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

  # return result if text was never changed
  defp build_diff(:prev, %{applied: [], result: result} = table), do: {table, result}

  defp build_diff(:prev, %{applied: [edit | _]} = table) do
    %{result: result} = table = PieceTable.undo!(table)

    {table, build_string(result, edit)}
  end

  # return result if text was never changed
  defp build_diff(:next, %{to_apply: [], result: result} = table), do: {table, result}

  defp build_diff(:next, %{to_apply: [edit | _]} = table) do
    %{result: result} = table = PieceTable.redo!(table)

    {table, build_string(result, edit)}
  end

  defp build_string(result, edit) do
    IO.iodata_to_binary([
      String.slice(result, 0, edit.position),
      highlight(edit.change, edit.text),
      String.slice(result, edit.position..-1)
    ])
  end

  defp highlight(op, text) when op in [:ins, "ins"],
    do: ~s|<span class="text-green-700">#{text}</span>|

  defp highlight(op, text) when op in [:del, "del"],
    do: ~s|<span class="text-red-700">#{text}</span>|

  @impl true
  def handle_event("prev", _params, socket) do
    {table, diff} = build_diff(:prev, socket.assigns.table)

    socket =
      socket
      |> assign(:table, table)
      |> assign(:text, diff)

    {:noreply, socket}
  end

  def handle_event("next", _params, socket) do
    {table, diff} = build_diff(:next, socket.assigns.table)

    socket =
      socket
      |> assign(:table, table)
      |> assign(:text, diff)

    {:noreply, socket}
  end
end
