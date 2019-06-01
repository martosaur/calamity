defmodule Calamity.CalamityTest do
  use Calamity.DataCase

  alias Calamity.Calamity

  describe "accounts" do
    alias Calamity.Account

    @valid_attrs %{data: %{}, name: "some name"}
    @update_attrs %{data: %{}, name: "some updated name"}
    @invalid_attrs %{data: nil, name: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Calamity.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Calamity.list_accounts() == [account]
    end

    test "search_accounts_by_name/1 can search for accounts" do
      account_fixture()
      account2 = account_fixture(%{data: %{}, name: "hello world"})
      assert Calamity.search_accounts_by_name("o w") == [account2]
    end

    test "search_accounts_by_name/1 search is can insensitive" do
      account1 = account_fixture()
      account2 = account_fixture(%{data: %{}, name: "SOME_NAME"})
      assert Calamity.search_accounts_by_name("some") == [account1, account2]
    end

    test "search_accounts_by_text/1 searches through names" do
      account1 = account_fixture()
      account_fixture(%{data: %{}, name: "hello world"})
      assert Calamity.search_accounts_by_text("name") == [account1]
    end

    test "search_accounts_by_text/1 searches through data" do
      account_fixture()
      account2 = account_fixture(%{data: %{"my" => %{"pinkie" => "pie"}}, name: "hello world"})
      assert Calamity.search_accounts_by_text("pinkie") == [account2]
    end

    test "search_accounts_by_map/1 searches by data" do
      account1 = account_fixture(%{data: %{"hello" => "world"}})
      account_fixture(%{data: %{"hello" => "pinkie"}, name: "some name 2"})
      assert Calamity.search_accounts_by_map(%{"hello" => "world"}) == [account1]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Calamity.get_account!(account.id) == account
    end

    test "get_account!/1 returns the account with given name" do
      account = account_fixture()
      assert Calamity.get_account!(account.name) == account
    end

    test "get_account!/1 has id in prioriry" do
      account1 = account_fixture(%{data: %{}, name: "first"})
      account2 = account_fixture(%{data: %{}, name: "#{account1.id}"})
      assert Calamity.get_account!(account2.name) == account1
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Calamity.create_account(@valid_attrs)
      assert account.data == %{}
      assert account.name == "some name"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calamity.create_account(@invalid_attrs)
    end

    test "create_account/1 name should be uniq" do
      account = account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Calamity.create_account(%{name: account.name, data: %{}})
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, account} = Calamity.update_account(account, @update_attrs)
      assert %Account{} = account
      assert account.data == %{}
      assert account.name == "some updated name"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Calamity.update_account(account, @invalid_attrs)
      assert account == Calamity.get_account!(account.id)
    end

    test "update_account/2 name should be unique" do
      account1 = account_fixture()
      account2 = account_fixture(%{name: "hello"})

      assert {:error, %Ecto.Changeset{}} =
               Calamity.update_account(account1, %{name: account2.name})
    end

    test "delete_account/1 deletes the account and private pool" do
      account = account_fixture()
      assert {:ok, %Account{}} = Calamity.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Calamity.get_account!(account.id) end

      assert_raise Ecto.NoResultsError, fn -> Calamity.get_pool!(account.name) end
    end

    test "change_account/1 returns an account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Calamity.change_account(account)
    end

    test "lock_account/1 lock account if it is not locked" do
      account = account_fixture()
      assert {:ok, acc} = Calamity.lock_account(account)
      assert acc.locked == true
      assert acc.locked_at != nil
    end

    test "lock_account/1 cant lock if already locked" do
      account = account_fixture(locked: true)
      assert {:error, :no_account_to_lock} = Calamity.lock_account(account)
    end

    test "unlock_account/1 unlocks account if it is locked" do
      account = account_fixture(%{locked: true, locked_at: DateTimeHelpers.utc_now()})
      assert {:ok, %Account{locked: false, locked_at: nil}} = Calamity.unlock_account(account)
    end

    test "unlock_account/1 cannot unlock account if it is not locked" do
      account = account_fixture(%{locked: false})
      assert {:error, :not_locked} = Calamity.unlock_account(account)
    end

    test "unlock_accounts_locked_for_more_than/1 unlock accounts based on timestamp" do
      account1 = account_fixture(%{name: "old", locked: true})

      account2 =
        Repo.insert!(%Account{
          name: "new",
          locked: true,
          data: %{},
          locked_at: DateTimeHelpers.utc_now() |> DateTime.add(10)
        })

      Calamity.unlock_accounts_locked_for_more_than(-1)
      assert %Account{locked: false, locked_at: nil} = Calamity.get_account!(account1.id)
      assert %Account{locked: true} = Calamity.get_account!(account2.id)
    end
  end

  describe "pools" do
    alias Calamity.Pool
    alias Calamity.Account

    @valid_attrs %{name: "some pool name"}
    @update_attrs %{name: "some updated pool name"}
    @invalid_attrs %{name: nil}

    def pool_fixture(attrs \\ %{}) do
      {:ok, pool} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Calamity.create_pool()

      pool
    end

    test "list_pools/0 returns all pools" do
      pool = pool_fixture()
      assert Calamity.list_pools() == [pool]
    end

    test "get_pool!/1 returns the pool with given id" do
      pool = pool_fixture()
      assert Calamity.get_pool!(pool.id) == pool
    end

    test "get_pool!/1 returns the pool with given name" do
      pool = pool_fixture()
      assert Calamity.get_pool!(pool.name) == pool
    end

    test "creating account also created private pool with the same name" do
      account = account_fixture()

      assert Repo.get_by!(Pool, name: account.name, private: true)
    end

    test "create_pool/1 with valid data creates a pool" do
      assert {:ok, %Pool{} = pool} = Calamity.create_pool(@valid_attrs)
      assert pool.name == "some pool name"
    end

    test "create_pool/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calamity.create_pool(@invalid_attrs)
    end

    test "create_pool/1 name should be unique" do
      pool = pool_fixture()

      assert {:error, %Ecto.Changeset{}} = Calamity.create_pool(%{name: pool.name})
    end

    test "update_pool/2 with valid data updates the pool" do
      pool = pool_fixture()
      assert {:ok, %Pool{} = pool} = Calamity.update_pool(pool, @update_attrs)
      assert pool.name == "some updated pool name"
    end

    test "update_pool/2 with invalid data returns error changeset" do
      pool = pool_fixture()
      assert {:error, %Ecto.Changeset{}} = Calamity.update_pool(pool, @invalid_attrs)
      assert pool == Calamity.get_pool!(pool.id)
    end

    test "update_pool/2 name should be unique" do
      pool1 = pool_fixture()
      pool2 = pool_fixture(%{name: "hello"})
      assert {:error, %Ecto.Changeset{}} = Calamity.update_pool(pool1, %{name: pool2.name})
      assert pool1 == Calamity.get_pool!(pool1.id)
    end

    test "delete_pool/1 deletes the pool" do
      pool = pool_fixture()
      assert {:ok, %Pool{}} = Calamity.delete_pool(pool)
      assert_raise Ecto.NoResultsError, fn -> Calamity.get_pool!(pool.id) end
    end

    test "change_pool/1 returns a pool changeset" do
      pool = pool_fixture()
      assert %Ecto.Changeset{} = Calamity.change_pool(pool)
    end

    test "add_account_to_pool/2 adds account to pool" do
      pool = pool_fixture()
      account = account_fixture()
      assert {:ok, %Pool{}} = Calamity.add_account_to_pool(account, pool)
    end

    test "add_account_to_pool/2 is idempotent" do
      pool = pool_fixture()
      account = account_fixture()
      assert {:ok, %Pool{}} = Calamity.add_account_to_pool(account, pool)
      assert {:ok, %Pool{}} = Calamity.add_account_to_pool(account, pool)
    end

    test "remove_account_from_pool/2 removes account from a pool" do
      pool = pool_fixture()
      account = account_fixture()
      assert {:ok, %Pool{}} = Calamity.add_account_to_pool(account, pool)
      assert {:ok, %Pool{}} = Calamity.remove_account_from_pool(account, pool)
    end

    test "lock account in a pool" do
      pool = pool_fixture()
      account = account_fixture()
      assert {:ok, %Pool{}} = Calamity.add_account_to_pool(account, pool)
      assert {:ok, %Account{}} = Calamity.lock_account_in_pool(pool)
      a = Calamity.get_account!(account.id)
      assert a.locked == true
      assert a.locked_at != nil
    end

    test "lock account in pool: chooses unlocked account" do
      pool = pool_fixture()
      account1 = account_fixture(%{locked: true})
      account2 = account_fixture(%{name: "second"})
      Calamity.add_account_to_pool(account1, pool)
      Calamity.add_account_to_pool(account2, pool)
      assert {:ok, %Account{name: "second", locked: true}} = Calamity.lock_account_in_pool(pool)
    end

    test "lock account in pool: error if no account" do
      pool = pool_fixture()
      account1 = account_fixture(locked: true)
      Calamity.add_account_to_pool(account1, pool)
      assert {:error, :no_account_to_lock} = Calamity.lock_account_in_pool(pool)
    end
  end
end
