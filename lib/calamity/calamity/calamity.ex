defmodule Calamity.Calamity do
  @moduledoc """
  The Calamity context.
  """

  import Ecto.Query, warn: false
  alias Calamity.Repo

  alias Calamity.Calamity.Account
  alias Calamity.Calamity.Pool

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts() do
    Repo.all(Account)
  end

  @doc """
  Search for account name and returns a list of accounts.

  ## Examples

    iex> search_accounts_by_name("hello world")
    [%Account{}, ...]

  """
  def search_accounts_by_name(search) do
    search_string = "%#{search}%"

    Account
    |> where([a], ilike(a.name, ^search_string))
    |> Repo.all()
  end

  @doc """
  Makes a full text search within a name + data fields

  ## Examples

    iex> search_accounts_by_text("world")
    [%Account{}, ...]

  """
  def search_accounts_by_text(search) do
    Account
    |> where(
      [a],
      fragment(
        "(to_tsvector('english', coalesce(?, '')) || jsonb_to_tsvector('english', coalesce(?, '{}'::jsonb), '[\"all\"]'::jsonb)) @@ websearch_to_tsquery('english', ?)",
        a.name,
        a.data,
        ^search
      )
    )
    |> Repo.all()
  end

  @doc """
  Makes a json search within a data field

  ## Examples

    iex> search_accounts_by_text(%{"hello" => "world"})
    [%Account{}, ...]

  """
  def search_accounts_by_map(search) do
    Account
    |> where([a], fragment("? @> ?", a.data, ^search))
    |> Repo.all()
  end

  @doc """
  Gets a single account by id or name.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id) do
    cond do
      is_integer(id) ->
        Repo.get!(Account, id)

      match?({_, ""}, Integer.parse(id)) ->
        Repo.get!(Account, id)

      true ->
        Repo.get_by!(Account, name: id)
    end
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{source: %Account{}}

  """
  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end

  @doc """
  Locks an account if possible
  ## Examples

      iex> lock_account(account)
      {:ok, %Account{}}

  """
  def lock_account(%Account{locked: true} = account) do
    error_changeset =
      account
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.add_error(:locked, "already locked")

    {:error, error_changeset}
  end

  def lock_account(%Account{locked: false} = account) do
    update_account(account, %{locked: true})
  end

  @doc """
  Returns the list of pools.

  ## Examples

      iex> list_pools()
      [%Pool{}, ...]

  """
  def list_pools do
    Repo.all(Pool)
  end

  @doc """
  Gets a single pool.

  Raises `Ecto.NoResultsError` if the Pool does not exist.

  ## Examples

      iex> get_pool!(123)
      %Pool{}

      iex> get_pool!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pool!(id) do
    cond do
      is_integer(id) ->
        Repo.get!(Pool, id)

      match?({_, ""}, Integer.parse(id)) ->
        Repo.get!(Pool, id)

      true ->
        Repo.get_by!(Pool, name: id)
    end
  end

  @doc """
  Creates a pool.

  ## Examples

      iex> create_pool(%{field: value})
      {:ok, %Pool{}}

      iex> create_pool(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pool(attrs \\ %{}) do
    %Pool{}
    |> Pool.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pool.

  ## Examples

      iex> update_pool(pool, %{field: new_value})
      {:ok, %Pool{}}

      iex> update_pool(pool, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pool(%Pool{} = pool, attrs) do
    pool
    |> Pool.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Pool.

  ## Examples

      iex> delete_pool(pool)
      {:ok, %Pool{}}

      iex> delete_pool(pool)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pool(%Pool{} = pool) do
    Repo.delete(pool)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pool changes.

  ## Examples

      iex> change_pool(pool)
      %Ecto.Changeset{source: %Pool{}}

  """
  def change_pool(%Pool{} = pool) do
    Pool.changeset(pool, %{})
  end

  @doc """
  Adds account to a pool

  """
  def add_account_to_pool(%Account{} = account, %Pool{} = pool) do
    pool = Repo.preload(pool, :accounts)

    pool
    |> change_pool()
    |> Ecto.Changeset.put_assoc(:accounts, [account | pool.accounts])
    |> Repo.update()
  end

  @doc """
  Removes account from a pool

  """
  def remove_account_from_pool(%Account{} = account, %Pool{} = pool) do
    pool = Repo.preload(pool, :accounts)

    accounts =
      pool.accounts
      |> Enum.reject(&(&1.id == account.id))

    pool
    |> change_pool()
    |> Ecto.Changeset.put_assoc(:accounts, accounts)
    |> Repo.update()
  end
end
