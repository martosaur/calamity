defmodule Calamity.Repo.Migrations.AddUniqNameContraint do
  use Ecto.Migration

  def change do
    create unique_index(:accounts, [:name])
  end
end
