defmodule CalamityWeb.MinimumAuth do
  import Plug.Conn

  def init(_opts) do
    "Bearer #{System.get_env("CALAMITY_AUTH_TOKEN")}"
  end

  def call(conn, auth_header_value) do
    conn
    |> get_req_header("authorization")
    |> IO.inspect()
    |> case do
      [^auth_header_value] ->
        conn

      _ ->
        conn
        |> send_resp(:unauthorized, "Request unauthorized")
        |> halt()
    end
  end
end
