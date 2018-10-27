defmodule Calamity.Calamity do
  @moduledoc """
  The Calamity context.
  """

  import Ecto.Query, warn: false
  alias Calamity.Repo

  alias Calamity.Calamity.Account

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
end
