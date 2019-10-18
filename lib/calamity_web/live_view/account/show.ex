defmodule CalamityWeb.Live.Account.Show do
  use Phoenix.LiveView
  alias Calamity.Calamity

  def render(assigns) do
    CalamityWeb.AccountView.render("show.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :refresh)

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _path, socket) do
    {:noreply, fetch(socket, id)}
  end

  def handle_info(:refresh, socket) do
    {:noreply, fetch(socket, socket.assigns.account_id)}
  end

  def handle_event("lock", %{"account_id" => id}, socket) do
    account =
      id
      |> String.to_integer()
      |> Calamity.get_account!()

    Calamity.lock_account(account)
    {:noreply, socket}
  end

  def handle_event("unlock", %{"account_id" => id}, socket) do
    account =
      id
      |> String.to_integer()
      |> Calamity.get_account!()

    Calamity.unlock_account(account)
    {:noreply, socket}
  end

  def fetch(socket, id) do
    assign(socket, account: Calamity.get_account!(id), account_id: id)
  end
end
