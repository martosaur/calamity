defmodule Calamity.Repo.Migrations.AccountsNameDataSearchIdx do
  use Ecto.Migration

  def change do
    create index(:accounts, ["(to_tsvector('english', coalesce(name, '')) || jsonb_to_tsvector('english', coalesce(data, '{}'::jsonb), '[\"all\"]'::jsonb))"], name: :accounts_name_data_idx, using: "GIN")
  end
end
