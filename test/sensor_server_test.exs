defmodule SensorServerTest do
  use ExUnit.Case

  alias Servy.SensorServer, as: Server

  test "gives back snapshots and bigfoot location" do
    Server.start_link()
    {snapshots, location} = Server.get_sensor_data()
    [snap1, snap2, snap3] = snapshots

    assert length(snapshots) == 3
    assert String.ends_with?(snap1, "snapshot.jpg")
    assert String.ends_with?(snap2, "snapshot.jpg")
    assert String.ends_with?(snap3, "snapshot.jpg")
    assert location == %{ lat: "29.0469 N", lng: "98.8667 W"}
  end
end
