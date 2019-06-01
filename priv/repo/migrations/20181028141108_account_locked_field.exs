defmodule Calamity.Repo.Migrations.AccountLockedField do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:locked, :boolean, default: false, null: false)
      add(:locked_at, :utc_datetime, default: nil)
    end
  end
end
