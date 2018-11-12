defmodule CalamityWeb.PoolView do
  use CalamityWeb, :view
  alias CalamityWeb.PoolView

  def render("index.json", %{pools: pools}) do
    %{data: render_many(pools, PoolView, "pool.json")}
  end

  def render("show.json", %{pool: pool}) do
    %{data: render_one(pool, PoolView, "pool.json")}
  end

  def render("pool.json", %{pool: pool}) do
    %{id: pool.id, name: pool.name}
  end
end
