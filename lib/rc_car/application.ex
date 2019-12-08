defmodule RcCar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RcCar.Supervisor]
    children =
      [
      {Plug.Cowboy, scheme: :http, plug: RcCar.Controller, options: [port: 8080]}
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: RcCar.Worker.start_link(arg)
      # {RcCar.Worker, arg},
    ]
  end

  def children(_target) do
    [
      RcCar.Vehicle
    ]
  end

  def target() do
    Application.get_env(:rc_car, :target)
  end
end
