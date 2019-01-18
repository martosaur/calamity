defmodule Calamity.Repo.Migrations.CreatePools do
  use Ecto.Migration

  def change do
    create table(:pools) do
      add(:name, :string)
      add(:private, :boolean)

      timestamps()
    end

    create(unique_index(:pools, [:name, :private]))

    create table(:pool_accounts, primary_key: false) do
      add(:pool_id, references(:pools, on_delete: :delete_all))
      add(:account_id, references(:accounts, on_delete: :delete_all))
    end
  end
end
