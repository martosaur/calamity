use Mix.Config

config :calamity,
  start_workers: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :calamity, CalamityWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :calamity, Calamity.Repo,
  username: "postgres",
  password: "postgres",
  database: "calamity_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
