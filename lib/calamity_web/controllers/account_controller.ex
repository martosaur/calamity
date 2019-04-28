defmodule CalamityWeb.AccountController do
  use CalamityWeb, :controller

  alias Calamity.Calamity
  alias Calamity.Account

  action_fallback(CalamityWeb.FallbackController)

  def index(conn, %{"search" => search}) do
    accounts = Calamity.search_accounts_by_name(search)
    render(conn, "index.json", accounts: accounts)
  end

  def index(conn, _params) do
    accounts = Calamity.list_accounts()
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Calamity.create_account(account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Calamity.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Calamity.get_account!(id)

    with {:ok, %Account{} = account} <- Calamity.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Calamity.get_account!(id)

    with {:ok, %Account{}} <- Calamity.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end

  def search(conn, %{"search" => search}) when is_bitstring(search) do
    accounts = Calamity.search_accounts_by_text(search)
    render(conn, "index.json", accounts: accounts)
  end

  def search(conn, %{"search" => search}) when is_map(search) do
    accounts = Calamity.search_accounts_by_map(search)
    render(conn, "index.json", accounts: accounts)
  end

  def lock(conn, %{"id" => id}) do
    account = Calamity.get_account!(id)

    with {:ok, %Account{} = account} <- Calamity.lock_account(account) do
      render(conn, "show.json", account: account)
    end
  end

  def unlock(conn, %{"id" => id}) do
    account = Calamity.get_account!(id)

    with {:ok, %Account{} = account} <- Calamity.unlock_account(account) do
      render(conn, "show.json", account: account)
    end
  end
end
