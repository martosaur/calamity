defmodule Calamity.AccountUnlocker do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, Application.get_env(:calamity, :unlock_after))
  end

  def init(unlock_after) do
    Logger.info("Starting AccountUnlocker worker with unlock_after=#{inspect(unlock_after)}")
    send(self(), :work)
    {:ok, unlock_after}
  end

  def handle_info(:work, unlock_after) do
    schedule_next_run(unlock_after)
    Logger.info("Time has come to unlock accounts...")
    {n, _} = Calamity.Calamity.unlock_accounts_locked_for_more_than(unlock_after)
    Logger.info("Accounts unlocked: #{inspect(n)}")
    {:noreply, unlock_after}
  end

  defp schedule_next_run(unlock_after) do
    Logger.info("Scheduling next unlock")
    Process.send_after(self(), :work, min(unlock_after, 60) * 1000)
  end
end
