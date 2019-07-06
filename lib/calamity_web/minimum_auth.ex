defmodule CalamityWeb.MinimumAuth do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    auth_header = "Bearer #{Application.get_env(:calamity, :auth_token)}"

    conn
    |> get_req_header("authorization")
    |> case do
      [^auth_header] ->
        conn

      _ ->
        conn
        |> send_resp(:unauthorized, "Request unauthorized")
        |> halt()
    end
  end
end
