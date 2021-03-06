defmodule CalamityWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CalamityWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(CalamityWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(CalamityWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :no_account_to_lock}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(CalamityWeb.ErrorView)
    |> render("error.json", reason: "Couldn't find an account to lock")
  end

  def call(conn, {:error, :not_locked}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(CalamityWeb.ErrorView)
    |> render("error.json", reason: "Account is not locked")
  end
end
