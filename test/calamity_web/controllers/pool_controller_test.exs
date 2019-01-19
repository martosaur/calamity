defmodule CalamityWeb.PoolControllerTest do
  use CalamityWeb.ConnCase

  alias Calamity.Calamity
  alias Calamity.Pool

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:pool) do
    {:ok, pool} = Calamity.create_pool(@create_attrs)
    pool
  end

  def fixture(:account) do
    {:ok, account} = Calamity.create_account(%{name: "some account", data: %{}})
    account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all pools", %{conn: conn} do
      conn = get(conn, Routes.pool_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create pool" do
    test "renders pool when data is valid", %{conn: conn} do
      conn = post(conn, Routes.pool_path(conn, :create), pool: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.pool_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.pool_path(conn, :create), pool: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update pool" do
    setup [:create_pool]

    test "renders pool when data is valid", %{conn: conn, pool: %Pool{id: id} = pool} do
      conn = put(conn, Routes.pool_path(conn, :update, pool), pool: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.pool_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, pool: pool} do
      conn = put(conn, Routes.pool_path(conn, :update, pool), pool: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete pool" do
    setup [:create_pool]

    test "deletes chosen pool", %{conn: conn, pool: pool} do
      conn = delete(conn, Routes.pool_path(conn, :delete, pool))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.pool_path(conn, :show, pool))
      end
    end
  end

  describe "add account to pool" do
    setup [:create_pool, :create_account]

    test "adds account to pool", %{conn: conn, pool: pool, account: account} do
      conn = put(conn, Routes.pool_path(conn, :add_account, pool, account))
      assert %{"id" => id} = json_response(conn, 200)["data"]
    end

    test "account does not exist", %{conn: conn, pool: pool, account: account} do
      assert_error_sent 404, fn ->
        put(conn, Routes.pool_path(conn, :add_account, pool, %{account | id: 666}))
      end
    end
  end

  describe "remove account from pool" do
    setup [:create_pool_with_account]

    test "remove account from a pool", %{conn: conn, pool: pool, account: account} do
      conn = put(conn, Routes.pool_path(conn, :remove_account, pool, account))
      assert %{"id" => id} = json_response(conn, 200)["data"]
    end
  end

  describe "lock account in pool" do
    setup [:create_pool_with_account]

    test "lock account in a pool", %{conn: conn, pool: pool, account: account} do
      conn = post(conn, Routes.pool_path(conn, :lock, pool))
      assert %{"locked" => true} = json_response(conn, 200)["data"]
    end
  end

  defp create_pool(_) do
    pool = fixture(:pool)
    {:ok, pool: pool}
  end

  defp create_account(_) do
    account = fixture(:account)
    {:ok, account: account}
  end

  defp create_pool_with_account(_) do
    pool = fixture(:pool)
    account = fixture(:account)
    Calamity.add_account_to_pool(account, pool)
    {:ok, [account: account, pool: pool]}
  end
end
