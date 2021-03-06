# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :calamity,
  ecto_repos: [Calamity.Repo],
  unlock_after: 3600

# Configures the endpoint
config :calamity, CalamityWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9+wIKx6FJb3Vf/kPnb/LWn2blnu6BzFoPRtBPPB4HCBKBNWQRt5ZJZ6IFCOSm4E5",
  render_errors: [view: CalamityWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Calamity.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
