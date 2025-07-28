defmodule HttpServerTest do
  use ExUnit.Case
  doctest Servy.HttpServer

  alias Servy.HttpServer

  test "properly responds to multiple requests" do
    spawn(HttpServer, :start_server, [4000])

    results =
      ["/wildthings", "/bears", "/api/bears", "/faq", "/contact", "/bears/1"]
      |> Enum.map(&Task.async(fn -> HTTPoison.get("http://localhost:4000#{&1}") end))
      |> Enum.map(&Task.await(&1))

    for result <- results do
      {:ok, resp} = result
      assert resp.status_code == 200
    end
  end
end
