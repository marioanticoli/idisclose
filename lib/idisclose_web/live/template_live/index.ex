defmodule IdiscloseWeb.TemplateLive.Index do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [to_action: 1, authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Documents
  alias Idisclose.Documents.Template

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :templates, list_templates(socket))}
  end

  defp list_templates(socket) do
    if authorized?(socket, Template, :index) do
      Documents.list_templates()
    else
      []
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    action = to_action(socket.assigns.live_action)

    socket =
      if authorized?(socket, Template, action) do
        apply_action(socket, socket.assigns.live_action, params)
      else
        put_error(socket, action)
      end

    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Template")
    |> assign(:template, Documents.get_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Template")
    |> assign(:template, %Template{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Templates")
    |> assign(:template, nil)
  end

  @impl true
  def handle_info({IdiscloseWeb.TemplateLive.FormComponent, {:saved, template}}, socket) do
    socket =
      if authorized?(socket, template, :create) do
        stream_insert(socket, :templates, template)
      else
        put_error(socket, :create)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket =
      if authorized?(socket, Template, :delete) do
        {:ok, template} = id |> Documents.get_template!() |> Documents.delete_template()
        stream_delete(socket, :templates, template)
      else
        put_error(socket, :delete)
      end

    {:noreply, socket}
  end
end
