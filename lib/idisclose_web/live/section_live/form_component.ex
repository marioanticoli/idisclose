defmodule IdiscloseWeb.SectionLive.FormComponent do
  use IdiscloseWeb, :live_component

  alias Idisclose.Documents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage section records in your database.</:subtitle>
      </.header>

      <.simple_form for={@form} id="section-form" phx-target={@myself} phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input id="editor" phx-hook="Editor" field={@form[:body]} type="textarea" label="Body" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Section</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{section: section} = assigns, socket) do
    changeset = Documents.change_section(section)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"section" => section_params}, socket) do
    changeset =
      socket.assigns.section
      |> Documents.change_section(section_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"section" => section_params}, socket) do
    save_section(socket, socket.assigns.action, section_params)
  end

  defp save_section(socket, :edit, section_params) do
    case Documents.update_section(socket.assigns.section, section_params) do
      {:ok, section} ->
        notify_parent({:saved, section})

        {:noreply,
         socket
         |> put_flash(:info, "Section updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_section(socket, :new, section_params) do
    case Documents.create_section(section_params) do
      {:ok, section} ->
        notify_parent({:saved, section})

        {:noreply,
         socket
         |> put_flash(:info, "Section created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
