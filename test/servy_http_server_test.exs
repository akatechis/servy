defmodule ServyHttpServerTest do
  use ExUnit.Case
  doctest Servy.HttpServer

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "properly responds to GET /bears" do
    server_pid = spawn(HttpServer, :start_server, [5000])

    request = """
    GET /bears HTTP/1.1
    Host: localhost:5000
    Accept: */*

    """
    {:ok, resp} = HttpClient.get("localhost", 5000, request)

    assert resp.is_ok
    assert resp.status_code == 200
    assert resp.http_version == "HTTP/1.1"
    assert resp.reason_phrase == "OK"
    assert resp.headers["content-type"] == "text/html"
    assert resp.body =~ "<li>Brutus (Grizzly)</li>"

    Process.exit(server_pid, :kill)
  end
end
