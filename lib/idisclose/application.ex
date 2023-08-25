defmodule Idisclose.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      IdiscloseWeb.Telemetry,
      # Start the Ecto repository
      Idisclose.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Idisclose.PubSub},
      # Start the Endpoint (http/https)
      IdiscloseWeb.Endpoint,
      # Start a worker by calling: Idisclose.Worker.start_link(arg)
      # {Idisclose.Worker, arg}
      cluster_child()
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Idisclose.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IdiscloseWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp cluster_child do
    topologies = Application.get_env(:libcluster, :topologies, [])
    {Cluster.Supervisor, [topologies, [name: Idisclose.ClusterSupervisor]]}
  end
end
