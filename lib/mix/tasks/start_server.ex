defmodule Mix.Tasks.StartServer do
  use Mix.Task
  alias Servy.HttpServer

  @shortdoc "Starts the Servy HTTP server"
  @requirements ["app.start"]

  def run(args) do
    [port | _] = args
    port = String.to_integer(port || "4000")
    IO.puts("Starting Servy HTTP server on port #{port}...")
    HttpServer.start_server(port)
  end
end
