defmodule IdiscloseWeb.TemplateLive.Show do
  use IdiscloseWeb, :live_view

  import Idisclose.Utils.Auth, only: [to_action: 1, authorized?: 3]
  import Idisclose.Utils.Liveview, only: [put_error: 2]

  alias Idisclose.Documents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    action = to_action(socket.assigns.live_action)

    socket =
      if authorized?(socket, Section, action) and authorized?(socket, Template, action) and
           authorized?(socket, SectionTemplate, action) do
        socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
        |> assign(:section, Documents.get_section!(id))

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
        socket
        |> assign(:page_title, page_title)
        |> assign(:template, template)
        # Get all sections to add associations
        |> assign(:sections, sections)
      else
        put_error(socket, action)
      end

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Template"
  defp page_title(:edit), do: "Edit Template"
  defp page_title(:new_assoc), do: "New Association"

  @impl true
  def handle_event("delete", %{"template_id" => template_id, "section_id" => section_id}, socket) do
    :ok = Documents.delete_section_template(section_id, template_id)
    template = Documents.get_template!(template_id)

    {:noreply, assign(socket, :template, template)}
  end
end
