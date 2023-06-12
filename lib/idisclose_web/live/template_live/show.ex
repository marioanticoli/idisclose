defmodule IdiscloseWeb.TemplateLive.Show do
  use IdiscloseWeb, :live_view

  alias Idisclose.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    template = Documents.get_template!(id)
    page_title = page_title(socket.assigns.live_action)

    # get the ID of all the sections already associated to the template
    sections =
      Enum.map(template.sections, & &1.id)
      # return sections still not associated
      |> Documents.list_sections_not_associated()
      # map them to return only ID and name
      |> Enum.map(&{&1.title, &1.id})

    # assign data into the socket
    socket =
      socket
      |> assign(:page_title, page_title)
      |> assign(:template, template)
      # Get all sections to add associations
      |> assign(:sections, sections)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Template"
  defp page_title(:edit), do: "Edit Template"
  defp page_title(:new_assoc), do: "New Association"
end
