defmodule CalamityWeb.Live.Account.Index do
  use Phoenix.LiveView
  alias Calamity.Calamity

  def render(assigns) do
    CalamityWeb.AccountView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :refresh)

    {:ok, fetch(socket)}
  end

  def handle_info(:refresh, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("lock", %{"account_id" => id}, socket) do
    Calamity.lock_account(id)
    {:noreply, socket}
  end

  def handle_event("unlock", %{"account_id" => id}, socket) do
    Calamity.unlock_account(id)
    {:noreply, socket}
  end

  def fetch(socket) do
    assign(socket, accounts: Calamity.list_accounts())
  end
end
