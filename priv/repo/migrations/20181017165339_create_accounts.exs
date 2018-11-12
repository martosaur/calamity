defmodule Calamity.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:name, :string)
      add(:data, :map)

      timestamps()
    end
  end
end
