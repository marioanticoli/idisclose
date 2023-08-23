import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :idisclose, IdiscloseWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: false

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Idisclose.Finch

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

########################
# Clustering
########################

config :libcluster,
  topologies: [
    k8s: [
      # maybe switch to Elixir.Cluster.Strategy.Kubernetes.DNS
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "idisclose-web",
        kubernetes_selector: System.get_env("K8_SELECTOR", "service=idisclose-web"),
        polling_interval: 10_000
      ]
    ]
  ]
