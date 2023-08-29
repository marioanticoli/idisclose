defmodule Idisclose.Utils.Auth do
  @moduledoc """
  Utility module for authorization in the iDisclose application.

  This module provides functions to authorize users for specific actions
  based on policies defined in the Idisclose.Policy module.
  """
  alias Idisclose.Policy
  alias Idisclose.Accounts.User
  alias Phoenix.LiveView

  @spec authorize(LiveView.Socket.t() | User.t(), module(), atom()) ::
          {:ok, struct()} | {:error, :not_authorized}
  def(authorize(%User{} = user, target, action)) do
    target
    |> struct(%{})
    |> Policy.authorize(action, user)
  end

  def authorize(socket, target, action) do
    user = get_user(socket)
    authorize(user, target, action)
  end

  def get_user(socket), do: get_in(socket, [Access.key(:assigns), Access.key(:current_user)])

  @spec authorized?(LiveView.Socket.t() | User.t(), module(), atom()) :: true | false
  def authorized?(resource, target, action) do
    action = to_action(action)

    case authorize(resource, target, action) do
      {:ok, _} -> true
      _ -> false
    end
  end

  @spec to_action(atom()) :: atom()
  def to_action(:new), do: :create
  def to_action(:index), do: :read
  def to_action(:edit), do: :update
  def to_action(:show), do: :read
  def to_action(:new_assoc), do: :create
  def to_action(action), do: action
end
