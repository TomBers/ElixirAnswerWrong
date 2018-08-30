defmodule Answerwrong.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Answerwrong.Repo, []),
      # Start the endpoint when the application starts
      supervisor(AnswerwrongWeb.Endpoint, []),
      supervisor(AnswerwrongWeb.Presence, []),
      worker(AnswerwrongWeb.Monitor, [%{}])
      # Start your own worker by calling: Answerwrong.Worker.start_link(arg1, arg2, arg3)
      # worker(Answerwrong.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Answerwrong.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AnswerwrongWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
