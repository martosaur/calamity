defmodule CalamityWeb.PoolController do
  use CalamityWeb, :controller

  alias Calamity.Calamity
  alias Calamity.Pool

  action_fallback CalamityWeb.FallbackController

  def index(conn, _params) do
    pools = Calamity.list_pools()
    render(conn, "index.json", pools: pools)
  end

  def create(conn, %{"pool" => pool_params}) do
    with {:ok, %Pool{} = pool} <- Calamity.create_pool(pool_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.pool_path(conn, :show, pool))
      |> render("show.json", pool: pool)
    end
  end

  def show(conn, %{"id" => id}) do
    pool = Calamity.get_pool!(id)
    render(conn, "show.json", pool: pool)
  end

  def update(conn, %{"id" => id, "pool" => pool_params}) do
    pool = Calamity.get_pool!(id)

    with {:ok, %Pool{} = pool} <- Calamity.update_pool(pool, pool_params) do
      render(conn, "show.json", pool: pool)
    end
  end

  def delete(conn, %{"id" => id}) do
    pool = Calamity.get_pool!(id)

    with {:ok, %Pool{}} <- Calamity.delete_pool(pool) do
      send_resp(conn, :no_content, "")
    end
  end

  def add_account(conn, %{"pool_id" => pool_id, "account_id" => account_id}) do
    pool = Calamity.get_pool!(pool_id)
    account = Calamity.get_account!(account_id)

    with {:ok, %Pool{} = pool} <- Calamity.add_account_to_pool(account, pool) do
      render(conn, "show.json", pool: pool)
    end
  end

  def remove_account(conn, %{"pool_id" => pool_id, "account_id" => account_id}) do
    pool = Calamity.get_pool!(pool_id)
    account = Calamity.get_account!(account_id)

    with {:ok, %Pool{} = pool} <- Calamity.remove_account_from_pool(account, pool) do
      render(conn, "show.json", pool: pool)
    end
  end
end
