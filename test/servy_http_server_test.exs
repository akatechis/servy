defmodule ServyHttpServerTest do
  use ExUnit.Case
  doctest Servy.HttpServer

  alias Servy.HttpServer

  test "properly responds to multiple requests" do
    spawn(HttpServer, :start_server, [4000])

    test_pid = self()
    paths = ["/wildthings", "/bears", "/api/bears", "/faq", "/contact", "/bears/1"]

    for path <- paths do
      spawn(fn ->
        case HTTPoison.get("http://localhost:4000#{path}") do
          {:ok, response} ->
            send(test_pid, {:response, response})
          {:error, reason} ->
            send(test_pid, {:error, reason})
        end
      end)
    end

    for _ <- paths do
      receive do
        {flag, resp} ->
          assert flag == :response
          assert resp.status_code == 200
      end
    end
  end
end
