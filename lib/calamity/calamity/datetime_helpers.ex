defmodule DateTimeHelpers do
  def utc_now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
