defmodule CalamityWeb.AccountControllerTest do
  use CalamityWeb.ConnCase

  alias Calamity.Calamity
  alias Calamity.Account

  @create_attrs %{data: %{}, name: "some name"}
  @update_attrs %{data: %{}, name: "some updated name"}
  @invalid_attrs %{data: nil, name: nil}

  def fixture(:account) do
    {:ok, account} = Calamity.create_account(@create_attrs)
    account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_account]

    test "lists all accounts", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index))
      assert json_response(conn, 200)["data"] |> length() == 1
    end

    test "search for accounts", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index, search: "2"))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "search" do
    setup [:create_account]

    test "performs a full text search for account" do
      conn = post(build_conn(), Routes.account_path(build_conn(), :search, search: "name"))
      assert json_response(conn, 200)["data"] |> length() == 1

      conn = post(build_conn(), Routes.account_path(build_conn(), :search, search: "hello"))
      assert json_response(conn, 200)["data"] |> length() == 0
    end

    test "performs a json search for account" do
      conn =
        post(
          build_conn(),
          Routes.account_path(build_conn(), :search, search: %{"hello" => "world"})
        )

      assert json_response(conn, 200)["data"] |> length() == 0
    end
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.account_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "data" => %{},
               "name" => "some name",
               "locked" => false,
               "locked_at" => nil,
               "unlock_at" => nil
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update account" do
    setup [:create_account]

    test "renders account when data is valid", %{conn: conn, account: %Account{id: id} = account} do
      conn = put(conn, Routes.account_path(conn, :update, account), account: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.account_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "data" => %{},
               "name" => "some updated name",
               "locked" => false,
               "locked_at" => nil,
               "unlock_at" => nil
             }
    end

    test "updates account by name", %{conn: conn, account: %Account{id: id} = account} do
      conn =
        put(conn, Routes.account_path(conn, :update, %{account | id: account.name}),
          account: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.account_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "data" => %{},
               "name" => "some updated name",
               "locked" => false,
               "locked_at" => nil,
               "unlock_at" => nil
             }
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn = put(conn, Routes.account_path(conn, :update, account), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "lock account" do
    setup [:create_account]

    test "locks chosen account", %{conn: conn, account: account} do
      conn = post(conn, Routes.account_path(conn, :lock, account))
      assert json_response(conn, 200)["data"]["locked"] == true
    end

    test "422 if already locked", %{conn: conn, account: account} do
      conn = post(conn, Routes.account_path(conn, :lock, account))
      assert response(conn, 200)

      conn = post(conn, Routes.account_path(conn, :lock, account))
      assert json_response(conn, 422)["error"] != %{}
    end
  end

  describe "unlock account" do
    setup [:create_account]

    test "unlocks chosen account", %{conn: conn, account: account} do
      conn = post(conn, Routes.account_path(conn, :lock, account))
      assert response(conn, 200)

      conn = post(conn, Routes.account_path(conn, :unlock, account))
      assert json_response(conn, 200)["data"]["locked"] == false
      assert json_response(conn, 200)["data"]["unlock_at"] == nil
    end

    test "422 if already locked", %{conn: conn, account: account} do
      conn = post(conn, Routes.account_path(conn, :unlock, account))
      assert json_response(conn, 422)["error"] != %{}
    end
  end

  describe "delete account" do
    setup [:create_account]

    test "deletes chosen account", %{conn: conn, account: account} do
      conn = delete(conn, Routes.account_path(conn, :delete, account))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.account_path(conn, :show, account))
      end)
    end

    test "deletes chosen account by name", %{conn: conn, account: account} do
      conn = delete(conn, Routes.account_path(conn, :delete, %{account | id: account.name}))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.account_path(conn, :show, account))
      end)
    end
  end

  defp create_account(_) do
    account = fixture(:account)
    {:ok, account: account}
  end
end
