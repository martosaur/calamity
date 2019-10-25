defmodule DateTimeHelpers do
  def utc_now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end

  def get_unlock_at(nil), do: Application.get_env(:calamity, :unlock_after) |> get_unlock_at()

  def get_unlock_at(lock_for) when is_binary(lock_for),
    do: String.to_integer(lock_for) |> get_unlock_at()

  def get_unlock_at(lock_for) do
    utc_now()
    |> DateTime.add(lock_for, :second)
  end
end
