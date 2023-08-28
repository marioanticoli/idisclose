defmodule IdiscloseWeb.UserLive.Show do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [to_action: 1, authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Accounts
  alias Idisclose.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    action = to_action(socket.assigns.live_action)

    socket =
      if authorized?(socket, User, action) do
        socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
        |> assign(:user, Accounts.get_user!(id))
      else
        put_error(socket, action)
      end

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end
