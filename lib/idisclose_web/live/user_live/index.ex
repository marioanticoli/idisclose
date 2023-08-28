defmodule IdiscloseWeb.UserLive.Index do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [to_action: 1, authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Accounts
  alias Idisclose.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, list_users(socket))}
  end

  defp list_users(socket) do
    if authorized?(socket, User, :index) do
      Accounts.list_users()
    else
      []
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    action = to_action(socket.assigns.live_action)

    socket =
      if authorized?(socket, User, action) do
        apply_action(socket, socket.assigns.live_action, params)
      else
        put_error(socket, action)
      end

    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({IdiscloseWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    socket =
      if authorized?(socket, user, :create) do
        stream_insert(socket, :users, user)
      else
        put_error(socket, :create)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket =
      if authorized?(socket, User, :delete) do
        {:ok, user} = id |> Accounts.get_user!() |> Accounts.delete_user()
        stream_delete(socket, :users, user)
      else
        put_error(socket, :delete)
      end

    {:noreply, socket}
  end
end
