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
      account1 = account_fixture()
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
      account2 = account_fixture(%{data: %{}, name: "hello world"})
      assert Calamity.search_accounts_by_text("name") == [account1]
    end

    test "search_accounts_by_text/1 searches through data" do
      account1 = account_fixture()
      account2 = account_fixture(%{data: %{"my" => %{"pinkie" => "pie"}}, name: "hello world"})
      assert Calamity.search_accounts_by_text("pinkie") == [account2]
    end

    test "search_accounts_by_map/1 searches by data" do
      account1 = account_fixture(%{data: %{"hello" => "world"}})
      account2 = account_fixture(%{data: %{"hello" => "pinkie"}, name: "some name 2"})
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

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Calamity.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Calamity.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Calamity.change_account(account)
    end
  end
end
