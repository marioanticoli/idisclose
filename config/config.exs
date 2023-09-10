# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :idisclose,
  ecto_repos: [Idisclose.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :idisclose, IdiscloseWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: IdiscloseWeb.ErrorHTML, json: IdiscloseWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Idisclose.PubSub,
  live_view: [signing_salt: "fM+aFwHa"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :idisclose, Idisclose.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  # disable debug logging
  level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

########################
# Clustering
########################

config :libcluster,
  debug: true,
  topologies: [local: [strategy: LibCluster.LocalStrategy]]

########################
# Scheduled jobs
########################

config :idisclose, Oban,
  repo: Idisclose.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

########################
# FileStorage
########################

config :idisclose, :file_storage,
  # To use S3 change to Idisclose.FileStorage.S3
  impl: Idisclose.FileStorage.Local,
  # Default path for Local implementation
  local_path: "priv/data",
  # Default region for S3 implementation
  region: ""

########################
# AWS
########################

config :ex_aws,
  debug_requests: true,
  json_codec: Jason,
  access_key_id: System.get_env("AWS_ACCESS_KEY", "AKIAIOSFODNN7EXAMPLE"),
  secret_access_key:
    System.get_env("SECRET_ACCESS_KEY", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")

########################
# S3
########################

port = System.get_env("S3_PORT", "9444") |> String.to_integer()

config :ex_aws, :s3,
  scheme: System.get_env("S3_SCHEME", "http://"),
  host: System.get_env("S3_HOST", "localhost"),
  port: port

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
