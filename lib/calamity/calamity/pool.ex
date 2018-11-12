defmodule Calamity.Calamity.Pool do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pools" do
    field(:name, :string)
    many_to_many(:accounts, Calamity.Calamity.Account, join_through: "pool_accounts")

    timestamps()
  end

  @doc false
  def changeset(pool, attrs) do
    pool
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
