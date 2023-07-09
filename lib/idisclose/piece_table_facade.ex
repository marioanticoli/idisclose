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
end
