defmodule Servy.VideoCam do

  def get_snapshot(camera_name) do
    :timer.sleep(1000) # Simulate delay for taking a snapshot

    # Example response returned from the API:
    "#{camera_name}-snapshot-#{:rand.uniform(1000)}.jpg"
  end
end
