defmodule Idisclose.FileStorage.Local do
  @moduledoc """
  Local implementation of FileStorage behaviour
  """
  @behaviour Idisclose.FileStorage

  @storage_path Application.compile_env!(:idisclose, :file_storage)[:local_path]

  @impl true
  def file_read(path, filename) do
    [@storage_path, path, filename]
    |> Path.join()
    |> File.read()
  end

  @impl true
  def file_write(path, filename, content) do
    [@storage_path, path, filename]
    |> Path.join()
    |> File.write(content)
  end

  @impl true
  def dir?(path) do
    @storage_path
    |> Path.join(path)
    |> File.dir?()
  end

  @impl true
  def mkdir(path) do
    @storage_path
    |> Path.join(path)
    |> File.mkdir()
  end
end
