defmodule Calamity.Calamity.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:data, :map)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :data])
    |> validate_required([:name, :data])
    |> unique_constraint(:name)
  end
end
