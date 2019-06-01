defmodule Calamity.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Calamity.Repo, []),
      # Start the endpoint when the application starts
      supervisor(CalamityWeb.Endpoint, [])
    ]

    workers =
      if Application.get_env(:calamity, :start_workers, true) do
        [worker(Calamity.AccountUnlocker, [])]
      else
        []
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Calamity.Supervisor]
    Supervisor.start_link(children ++ workers, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CalamityWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
