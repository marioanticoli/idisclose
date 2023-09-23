import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :idisclose, Idisclose.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOSTNAME", "localhost"),
  database: "idisclose_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :idisclose, IdiscloseWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zLE89QPU+pLCgwEJVa+pN9wamZbLH2eNm8Z8pALmKj/to5MFiXvFlxz7r4O5KobC",
  server: false

# In test we don't send emails.
config :idisclose, Idisclose.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

########################
# Scheduled jobs
########################

config :idisclose, Oban, testing: :inline

########################
# FileStorage
########################

config :idisclose, :file_storage,
  # To use S3 change to Idisclose.FileStorage.S3
  impl: Idisclose.FileStorage.Mock,
  # Default path for Local implementation
  local_path: System.tmp_dir!(),
  # Default region for S3 implementation
  region: ""
