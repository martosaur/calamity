defmodule CalamityWeb.Router do
  use CalamityWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CalamityWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api", CalamityWeb do
    pipe_through(:api)

    resources("/accounts", AccountController, only: [:index, :show, :create, :update, :delete])
    post("/accounts/search", AccountController, :search)
    post("/accounts/:id/lock", AccountController, :lock)

    resources("/pools", PoolController, only: [:index, :show, :create, :update, :delete])
    put("/pools/:pool_id/accounts/:account_id", PoolController, :add_account)
    delete("/pools/:pool_id/accounts/:account_id", PoolController, :remove_account)
  end
end
