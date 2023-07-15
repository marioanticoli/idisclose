defmodule Idisclose.PieceTableFacade do
  # delegate the execution to PieceTable library
  defdelegate new!(text), to: PieceTable
  defdelegate diff!(table, text), to: PieceTable.Differ
  defdelegate diff(table, text), to: PieceTable.Differ
  defdelegate undo!(table), to: PieceTable
  defdelegate redo!(table), to: PieceTable

  @storage_path "priv/data"

  @spec load(String.t(), String.t()) :: {:ok, PieceTable.t()} | {:error, File.posix()}
  def load(document_id, chapter_id) do
    with {:ok, raw_content} <-
           [@storage_path, document_id, chapter_id] |> Path.join() |> File.read(),
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

  @spec save(PieceTable.t(), String.t(), String.t()) ::
          {:ok, PieceTable.t()} | {:error, PieceTable.t()}
  def save(table, document_id, chapter_id) do
    path_dir = Path.join(@storage_path, document_id)
    maybe_mkdir(path_dir)

    with {:ok, raw_content} <- table |> map_from_struct() |> Jason.encode(),
         path <- Path.join(path_dir, chapter_id),
         :ok <- File.write(path, raw_content) do
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
    if not File.dir?(path_dir) do
      File.mkdir(path_dir)
    end
  end

  @spec diff_string(atom(), PieceTable.t(), String.t()) :: {PieceTable.t(), String.t()}
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
    %{result: result} =
      table = table |> PieceTable.redo!() |> IO.inspect() |> PieceTable.redo!() |> IO.inspect()

    {table, build_string_list(result, template, [edit1, edit2])}
  end

  # insert or delete
  def diff_string(:prev, %{applied: [edit | _]} = table, template) do
    %{result: result} = table = PieceTable.undo!(table)

    {table, build_string_list(result, template, edit)}
  end

  def diff_string(:next, %{to_apply: [edit | _]} = table, template) do
    %{result: result} = table = PieceTable.redo!(table)

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
