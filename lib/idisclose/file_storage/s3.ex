defmodule Idisclose.FileStorage.S3 do
  @moduledoc """
  S3 implementation of FileStorage behaviour
  """
  @behaviour Idisclose.FileStorage

  alias ExAws.S3

  @region Application.compile_env!(:idisclose, :file_storage)[:region]

  @impl true
  def file_read(path, filename) do
    case S3.get_object(path, filename) |> ExAws.request() do
      {:ok, %{body: content}} -> {:ok, content}
      err -> err
    end
  end

  @impl true
  def file_write(path, filename, content) do
    S3.put_object(path, filename, content) |> ExAws.request() |> handle_response()
  end

  @impl true
  def dir?(path) do
    case S3.get_bucket_location(path) |> ExAws.request() do
      {:ok, %{status_code: 200}} -> true
      _ -> false
    end
  end

  @impl true
  def mkdir(path) do
    S3.put_bucket(path, @region) |> ExAws.request() |> handle_response()
  end

  defp handle_response({:ok, _}), do: :ok
  defp handle_response(err), do: err
end
