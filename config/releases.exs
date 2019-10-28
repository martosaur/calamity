import Config

config :calamity,
  auth_token: System.fetch_env!("CALAMITY_AUTH_TOKEN"),
  unlock_after: System.get_env("CALAMITY_UNLOCK_AFTER", "3600") |> String.to_integer(),
  # 24 hours max
  max_lock_for: System.get_env("CALAMITY_MAX_LOCK_FOR", "86400") |> String.to_integer()

config :calamity, Calamity.Repo, url: System.fetch_env!("DATABASE_URL")

config :calamity, CalamityWeb.Endpoint,
  live_view: [
    signing_salt: System.fetch_env!("CALAMITY_LIVE_VIEW_SALT")
  ],
  url: [
    host: System.get_env("CALAMITY_HOST", "localhost"),
    port: System.get_env("CALAMITY_PORT", "4000") |> String.to_integer()
  ]

config :logger, level: System.get_env("LOG_LEVEL", "info") |> String.to_atom()
