defmodule Servy.VideoCam do
  def get_snapshot(camera_name) do
    # Simulate delay for taking a snapshot
    :timer.sleep(1000)

    # Example response returned from the API:
    "#{camera_name}-snapshot-#{:rand.uniform(1000)}.jpg"
  end
end
