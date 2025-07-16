defmodule Mix.Tasks.RunClient do
  use Mix.Task

  @shortdoc "Runs the Servy HTTP client"

  def run(_args) do
    path = "/api/bears"

    request = """
    GET #{path} HTTP/1.1
    Host: example.com
    Accept: */*

    """

    case Servy.HttpClient.get(request) do
      {:ok, response} ->
        IO.puts("Response received:")
        IO.puts(inspect(response))
        IO.puts("\n")
      {:error, reason} ->
        IO.puts("Error: #{reason}")
    end
  end
end
