defmodule Idisclose.PieceTableFacade.Impl do
  @behaviour Idisclose.PieceTableFacade

  @moduledoc """
  PieceTableFacade implementation
  """

  alias Idisclose.FileStorage.Fs

  # delegate the execution to PieceTable library
  @impl true
  defdelegate new!(text), to: PieceTable

  @impl true
  defdelegate diff!(table, text, user), to: PieceTable.Differ

  @impl true
  defdelegate diff(table, text, user), to: PieceTable.Differ

  @impl true
  defdelegate undo!(table), to: PieceTable

  @impl true
  defdelegate redo!(table), to: PieceTable

  @impl true
  def load(document_id, chapter_id) do
    with {:ok, raw_content} <- Fs.file_read(document_id, chapter_id),
         {:ok, params} <- Jason.decode(raw_content, keys: :atoms) do
      applied = Enum.map(params.applied, &rebuild_changes/1)
      to_apply = Enum.map(params.to_apply, &rebuild_changes/1)

      table = %PieceTable{
        original: params.original,
        result: params.result,
        applied: applied,
        to_apply: to_apply
      }

      {:ok, table}
    end
  end

  defp rebuild_changes(%{change: op} = change) do
    change = Map.put(change, :change, String.to_atom(op))
    struct(PieceTable.Change, change)
  end

  @impl true
  def get_text!(document_id, chapter_id) do
    case load(document_id, chapter_id) do
      {:ok, table} ->
        PieceTable.get_text!(table)

      _ ->
        chapter_id
        |> Idisclose.Documents.get_chapter!(:section)
        |> get_in([Access.key!(:section), Access.key!(:body)])
    end
  end

  @impl true
  def save(table, document_id, chapter_id) do
    with :ok <- maybe_mkdir(document_id),
         {:ok, raw_content} <- table |> map_from_struct() |> Jason.encode(),
         :ok <- Fs.file_write(document_id, chapter_id, raw_content) do
      # execute only if all conditions are true 
      {:ok, table}
    else
      _ ->
        {:error, table}
    end
  end

  # convert nested structs into map
  defp map_from_struct(table) do
    table
    |> Map.from_struct()
    |> update_in([:applied], &map_from_struct_list/1)
    |> update_in([:to_apply], &map_from_struct_list/1)
  end

  defp map_from_struct_list(list) when is_list(list), do: Enum.map(list, &Map.from_struct/1)

  defp maybe_mkdir(path_dir) do
    if Fs.dir?(path_dir) do
      :ok
    else
      Fs.mkdir(path_dir)
    end
  end

  @impl true
  # no changes, do nothing
  def diff_string(:prev, %{applied: [], result: result} = table, _), do: {table, result}
  def diff_string(:next, %{to_apply: [], result: result} = table, _), do: {table, result}

  # if changes happen at the same position it's an edit
  def diff_string(
        :prev,
        %{applied: [%{position: position} = edit1, %{position: position} = edit2 | _rest]} =
          table,
        template
      ) do
    %{result: result} = table = table |> PieceTable.undo!() |> PieceTable.undo!()

    {table, build_string_list(result, template, [edit1, edit2])}
  end

  def diff_string(
        :next,
        %{applied: [%{position: position} = edit1, %{position: position} = edit2 | _rest]} =
          table,
        template
      ) do
    %{result: result} = table = table |> PieceTable.redo!() |> PieceTable.redo!()

    {table, build_string_list(result, template, [edit1, edit2])}
  end

  # insert or delete
  def diff_string(:prev, %{applied: [edit | _]} = table, template) do
    %{result: result} = table = PieceTable.undo!(table)

    {table, build_string_list(result, template, edit)}
  end

  def diff_string(:next, %{to_apply: [edit | _]} = table, template) do
    result = PieceTable.get_text!(table)
    table = PieceTable.redo!(table)

    {table, build_string_list(result, template, edit)}
  end

  defp build_string_list(result, template, %{change: :ins} = edit) do
    [
      String.slice(result, 0, edit.position),
      build_from_template([edit.text], template.ins),
      String.slice(result, edit.position..-1)
    ]
  end

  defp build_string_list(result, template, %{change: :del} = edit) do
    next_pos = edit.position + String.length(edit.text)

    [
      String.slice(result, 0, edit.position),
      build_from_template([edit.text], template.del),
      String.slice(result, next_pos..-1)
    ]
  end

  defp build_string_list(result, template, edits) do
    %{del: [del], ins: [ins]} = Enum.group_by(edits, & &1.change)
    next_pos = del.position + String.length(del.text)

    [
      String.slice(result, 0, del.position),
      build_from_template([ins.text], template.edit),
      String.slice(result, next_pos..-1)
    ]
  end

  # interpolate text
  defp build_from_template(values, template) when is_list(values),
    do: :io_lib.format(template, values) |> to_string()
end
