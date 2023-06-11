defmodule IdiscloseWeb.TemplateLive.FormComponent do
  use IdiscloseWeb, :live_component

  alias Idisclose.Documents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage template records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="template-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Template</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{template: template} = assigns, socket) do
    changeset = Documents.change_template(template)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"template" => template_params}, socket) do
    changeset =
      socket.assigns.template
      |> Documents.change_template(template_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"template" => template_params}, socket) do
    save_template(socket, socket.assigns.action, template_params)
  end

  defp save_template(socket, :edit, template_params) do
    case Documents.update_template(socket.assigns.template, template_params) do
      {:ok, template} ->
        notify_parent({:saved, template})

        {:noreply,
         socket
         |> put_flash(:info, "Template updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_template(socket, :new, template_params) do
    case Documents.create_template(template_params) do
      {:ok, template} ->
        notify_parent({:saved, template})

        {:noreply,
         socket
         |> put_flash(:info, "Template created successfully")
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
