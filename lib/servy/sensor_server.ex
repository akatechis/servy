defmodule Servy.SensorServer do
  use GenServer
  alias Servy.VideoCam
  alias Servy.Tracker

  defmodule SensorState do
    defstruct snapshots: [], bigfoot_location: nil, refresh_interval: :timer.minutes(60)
  end

  # Client API

  def start_link(options) do
    refresh_interval = Keyword.get(options, :refresh_interval, 60)
    IO.puts("Starting Sensor Server w/ #{refresh_interval} min refresh interval...")
    GenServer.start_link(__MODULE__, :timer.minutes(refresh_interval), name: __MODULE__)
  end

  def init(refresh_interval) do
    {snapshots, bigfoot_location} = run_tasks_to_get_sensor_data()
    schedule_refresh(refresh_interval)

    state = %SensorState{
      snapshots: snapshots,
      bigfoot_location: bigfoot_location,
      refresh_interval: refresh_interval
    }

    {:ok, state}
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)
  end

  def get_sensor_data() do
    GenServer.call(__MODULE__, :get_sensor_data)
  end

  # Server API

  def handle_info(:refresh, state) do
    IO.puts("Caching sensor data...")
    {snapshots, bigfoot_location} = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)

    new_state = %{state | snapshots: snapshots, bigfoot_location: bigfoot_location}
    {:noreply, new_state}
  end

  def handle_call(
        :get_sensor_data,
        _from,
        %Servy.SensorServer.SensorState{snapshots: snapshots, bigfoot_location: bigfoot_location} =
          state
      ) do
    {:reply, {snapshots, bigfoot_location}, state}
  end

  def run_tasks_to_get_sensor_data do
    bigfoot_task = Task.async(fn -> Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    bigfoot_location = Task.await(bigfoot_task)

    {snapshots, bigfoot_location}
  end
end
