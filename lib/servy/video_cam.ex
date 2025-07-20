defmodule Servy.VideoCam do

  def get_snapshot(camera_name) do
    :timer.sleep(1000) # Simulate delay for taking a snapshot

    "#{camera_name}-snapshot.jpg"
  end
end
