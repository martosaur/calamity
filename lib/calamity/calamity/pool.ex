defmodule Calamity.Calamity.Pool do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pools" do
    field(:name, :string)
    field(:private, :boolean, default: false)

    many_to_many(:accounts, Calamity.Calamity.Account,
      join_through: "pool_accounts",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(pool, attrs) do
    pool
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :pools_name_private_index)
  end

  @doc false
  def private_changeset(pool, attrs) do
    pool
    |> cast(attrs, [:name, :private])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :pools_name_private_index)
  end
end
