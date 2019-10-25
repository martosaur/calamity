defmodule Calamity.AccountUnlocker do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    send(self(), :work)
    {:ok, nil}
  end

  def handle_info(:work, _) do
    schedule_next_run()
    {n, _} = Calamity.Calamity.unlock_accounts_with_unlock_at_due()
    Logger.debug("Accounts unlocked: #{inspect(n)}")
    {:noreply, nil}
  end

  defp schedule_next_run do
    next_unlock_in = 60

    Logger.debug(
      "Scheduling next unlock at #{inspect(DateTime.utc_now() |> DateTime.add(next_unlock_in))}"
    )

    Process.send_after(self(), :work, next_unlock_in * 1000)
  end
end
