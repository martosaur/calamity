defmodule Calamity.Calamity.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:data, :map)
    field(:name, :string)
    field(:locked, :boolean, default: false)
    field(:locked_at, :utc_datetime, default: nil)
    field(:unlock_at, :utc_datetime, default: nil)
    field(:lock_for, :integer, default: nil, virtual: true)

    many_to_many(:pools, Calamity.Calamity.Pool,
      join_through: "pool_accounts",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :data, :locked, :lock_for])
    |> validate_required([:name, :data])
    |> validate_number(:lock_for,
      less_than_or_equal_to: Application.get_env(:calamity, :max_lock_for, 86400)
    )
    |> unique_constraint(:name)
    |> prepare_changes(fn changeset ->
      if get_change(changeset, :locked) do
        put_change(changeset, :locked_at, DateTimeHelpers.utc_now())
        |> put_change(
          :unlock_at,
          get_change(changeset, :lock_for) |> DateTimeHelpers.get_unlock_at()
        )
      else
        put_change(changeset, :locked_at, nil)
        |> put_change(:unlock_at, nil)
      end
    end)
  end
end
