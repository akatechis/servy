defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting Services Supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.PledgeServer,
      Servy.PageNotFoundCounter,
      {Servy.SensorServer, refresh_interval: 20}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
