defmodule Idisclose.FileStorage do
  @callback file_read(String.t(), String.t()) :: {:ok, binary()} | {:error, any()}
  @callback file_write(String.t(), String.t(), binary()) :: :ok | {:error, any()}
  @callback dir?(String.t()) :: boolean()
  @callback mkdir(String.t()) :: :ok | {:error, any()}
end
