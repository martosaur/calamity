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
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:account, Account.changeset(%Account{}, attrs))
    |> Ecto.Multi.run(:new_pool, fn _repo, %{account: account} ->
      create_private_pool(%{name: account.name, private: true})
    end)
    |> Ecto.Multi.run(:add_account_to_pool, fn _repo, %{account: account, new_pool: new_pool} ->
      add_account_to_pool(account, new_pool)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{account: created_account}} ->
        {:ok, created_account}

      {:error, _, error, _} ->
        {:error, error}
    end
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
    [private_pool] = Repo.preload(account, pools: from(p in Pool, where: p.private == true)).pools

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:delete_account, account)
    |> Ecto.Multi.delete(:delete_private_pool, private_pool)
    |> Repo.transaction()
    |> case do
      {:ok, %{delete_account: account}} ->
        {:ok, account}

      error ->
        error
    end
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
  def lock_account(%Account{} = account) do
    account = Repo.preload(account, pools: from(p in Pool, where: p.private == true, limit: 1))

    account.pools
    |> hd()
    |> lock_account_in_pool()
  end

  def lock_account(id) do
    get_account!(id)
    |> lock_account()
  end

  @doc """
  Unlocks an account if possible
  ## Examples

      iex> lock_account(account)
      {:ok, %Account{}}

  """
  def unlock_account(%Account{locked: true} = account) do
    account
    |> Account.changeset(%{locked: false})
    |> Repo.update()
  end

  def unlock_account(%Account{}), do: {:error, :not_locked}

  def unlock_account(id) do
    get_account!(id)
    |> unlock_account()
  end

  def unlock_accounts_locked_for_more_than(n_seconds) do
    from(a in Account,
      where:
        a.locked == true and is_nil(a.locked_at) == false and
          a.locked_at < ago(^n_seconds, "second")
    )
    |> Repo.update_all(set: [locked: false, locked_at: nil])
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
        Repo.get_by!(Pool, name: id, private: false)
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

  def create_private_pool(attrs \\ %{}) do
    %Pool{}
    |> Pool.private_changeset(attrs)
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

  def lock_account_in_pool(%Pool{} = pool) do
    Repo.transaction(fn ->
      unlocked_accounts_query =
        from(a in Account, where: a.locked == false, limit: 1, lock: "FOR UPDATE NOWAIT")

      p = Repo.preload(pool, accounts: unlocked_accounts_query)

      case p.accounts do
        [] ->
          Repo.rollback(:no_account_to_lock)

        [account] ->
          update_account(account, %{locked: true})
          |> case do
            {:ok, account} ->
              account

            {:error, error} ->
              Repo.rollback(error)
          end
      end
    end)
  end
end
