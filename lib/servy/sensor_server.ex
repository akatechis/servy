defmodule Servy.SensorServer do
  use GenServer
  alias Servy.VideoCam
  alias Servy.Tracker

  # Client API

  def start_link() do
    IO.puts "Starting Sensor Server..."
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def get_sensor_data() do
    GenServer.call(__MODULE__, :get_sensor_data)
  end

  # Server API

  def handle_call(:get_sensor_data, _from, state) do
    bigfoot_task = Task.async(fn -> Tracker.get_location("bigfoot") end)

    snapshots = ["cam-1", "cam-2", "cam-3"]
    |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
    |> Enum.map(&Task.await/1)

    bigfoot_location = Task.await(bigfoot_task)

    {:reply, {snapshots, bigfoot_location}, state}
  end

end
