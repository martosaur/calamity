defmodule Calamity.Calamity.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:data, :map)
    field(:name, :string)
    field(:locked, :boolean, default: false)
    field(:locked_at, :utc_datetime, default: nil)

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
    |> prepare_changes(fn changeset ->
      if get_change(changeset, :locked) do
        put_change(changeset, :locked_at, DateTimeHelpers.utc_now())
      else
        put_change(changeset, :locked_at, nil)
      end
    end)
  end
end
