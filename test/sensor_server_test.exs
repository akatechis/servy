defmodule SensorServerTest do
  use ExUnit.Case

  alias Servy.SensorServer, as: Server
  @snapshot_regex ~r/^cam-\d-snapshot-\d+\.jpg$/

  test "gives back snapshots and bigfoot location" do
    Server.start_link([refresh_interval: 1])
    {snapshots, location} = Server.get_sensor_data()
    [snap1, snap2, snap3] = snapshots

    assert length(snapshots) == 3
    assert String.match?(snap1, @snapshot_regex)
    assert String.match?(snap2, @snapshot_regex)
    assert String.match?(snap3, @snapshot_regex)
    assert location == %{ lat: "29.0469 N", lng: "98.8667 W"}
  end
end
