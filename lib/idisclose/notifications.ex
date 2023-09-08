defmodule Idisclose.Notifications do
  @moduledoc """
  The Notications context.
  """

  alias IdiscloseWeb.Endpoint

  @doc """
  Sends a message to a user's private channel

  ## Examples

      iex> sys_msg!("text@example.com", "hello")
      :ok
  """
  @spec sys_msg!(String.t(), String.t()) :: :ok
  def sys_msg!(user, msg) do
    Endpoint.broadcast!("room:#{user}", "new_sys_msg", %{body: msg})
  end
end
