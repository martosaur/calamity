defmodule Calamity.Calamity.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:data, :map)
    field(:name, :string)
    field(:locked, :boolean, default: false)

    many_to_many(:pools, Calamity.Calamity.Pool,
      join_through: "pool_accounts",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :data, :locked])
    |> validate_required([:name, :data])
    |> unique_constraint(:name)
  end
end
