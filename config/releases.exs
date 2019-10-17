import Config

config :calamity,
  auth_token: System.fetch_env!("CALAMITY_AUTH_TOKEN"),
  unlock_after: System.get_env("CALAMITY_UNLOCK_AFTER", "3600") |> String.to_integer()

config :calamity, Calamity.Repo, url: System.fetch_env!("DATABASE_URL")
