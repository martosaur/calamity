defmodule Calamity.Repo.Migrations.CreatePools do
  use Ecto.Migration

  def change do
    create table(:pools) do
      add(:name, :string)

      timestamps()
    end

    create(unique_index(:pools, [:name]))

    create table(:pool_accounts, primary_key: false) do
      add(:pool_id, references(:pools))
      add(:account_id, references(:accounts))
    end
  end
end
