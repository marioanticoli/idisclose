defmodule IdiscloseWeb.DocumentLive.FormComponent do
  use IdiscloseWeb, :live_component

  alias Idisclose.Documents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage document records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:deadline]} type="date" label="Deadline" />
        <.input
          field={@form[:template_id]}
          type="select"
          label="Choose the template"
          options={@templates}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Document</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{document: document} = assigns, socket) do
    changeset = Documents.change_document(document)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    changeset =
      socket.assigns.document
      |> Documents.change_document(document_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"document" => document_params}, socket) do
    save_document(socket, socket.assigns.action, document_params)
  end

  defp save_document(socket, :edit, document_params) do
    case Documents.update_document(socket.assigns.document, document_params) do
      {:ok, document} ->
        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "Document updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_document(socket, :new, document_params) do
    case Documents.create_document(document_params) do
      {:ok, document} ->
        # TODO: modify to use transactions
        schedule_deadline_notification(document, socket.assigns.current_user.email)

        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "Document created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp schedule_deadline_notification(document, user) do
    msg = "Deadline for document '#{document.title}' will expire tomorrow."
    time = Time.new!(0, 0, 0)
    deadline = document.deadline |> DateTime.new!(time, "Etc/UTC") |> DateTime.add(-24, :hour)

    Idisclose.Scheduler.Worker.schedule(
      user,
      msg,
      deadline,
      document.id
    )
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
