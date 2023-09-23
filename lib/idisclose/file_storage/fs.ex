defmodule Idisclose.FileStorage.Fs do
  @moduledoc """
  Facade module to delegate to implementation
  """

  # The module attribute is inlined at compile time, reading from
  # config the module to use (local FS vs S3).
  @mod Application.compile_env!(:idisclose, :file_storage)[:impl]

  # Delegate execution to configured module 
  defdelegate file_read(path, filename), to: @mod
  defdelegate file_write(path, filename, content), to: @mod
  defdelegate dir?(path), to: @mod
  defdelegate mkdir(path), to: @mod
end
