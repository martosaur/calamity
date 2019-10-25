defmodule Calamity.Repo.Migrations.AccountUnlockAt do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:unlock_at, :utc_datetime, default: nil)
    end
  end
end
