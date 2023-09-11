defmodule Idisclose.Scheduler.Worker do
  @moduledoc """
  Scheduler worker
  """
  use Oban.Worker,
    queue: :events,
    max_attempts: 3

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => "sys_msg_" <> user, "message" => msg}}) do
    Idisclose.Notifications.sys_msg!(user, msg)
  end

  def perform(args) do
    Logger.warn(inspect(args))

    :ok
  end

  @spec schedule(String.t(), String.t(), DateTime.t(), any(), String.t()) ::
          {:ok, Oban.Job.t()} | {:error, Oban.Job.changeset() | term}
  def schedule(user, msg, datetime, ref, type \\ "sys_msg") do
    %{id: "#{type}_#{user}", message: msg, ref: ref}
    |> __MODULE__.new(scheduled_at: datetime, queue: :default)
    |> Oban.insert(unique: [period: :infinity, fields: [:args], keys: [:ref]])
  end
end
