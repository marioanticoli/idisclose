defmodule Idisclose.FileStorage.Fs do
  @moduledoc """
  Facade module to delegate to implementation
  """
  @mod Application.compile_env!(:idisclose, :file_storage)[:impl]

  defdelegate file_read(path, filename), to: @mod
  defdelegate file_write(path, filename, content), to: @mod
  defdelegate dir?(path), to: @mod
  defdelegate mkdir(path), to: @mod
end
