defmodule Servy.HttpServer do
  alias Servy.Handler

  def start_server_async(port) when is_integer(port) and port > 1023 do
    spawn(Servy.HttpServer, :start_server, [port])
  end

  def start_server(port) when is_integer(port) and port > 1023 do
    options = [:binary, packet: 0, active: false, reuseaddr: true, backlog: 10]
    {:ok, listen_socket} = :gen_tcp.listen(port, options)
    IO.puts("🎧 Listening for requests on port #{port}...\n")
    server_loop(listen_socket)
  end

  def server_loop(listen_socket) do
    IO.puts("⌛ Waiting for client connection...\n")
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    IO.puts("⚡ Connection accepted!\n")
    server_pid = spawn(fn -> serve(client_socket) end)
    :ok = :gen_tcp.controlling_process(client_socket, server_pid)
    server_loop(listen_socket)
  end

  def serve(client_socket) do
    client_socket
    |> read_request
    |> Handler.handle()
    |> write_response(client_socket)
  end

  def read_request(client_socket) do
    {:ok, request_txt} = :gen_tcp.recv(client_socket, 0)
    request_txt
  end

  def write_response(response_txt, client_socket) do
    :ok = :gen_tcp.send(client_socket, response_txt)
    :gen_tcp.close(client_socket)
    IO.puts("✅ Response sent!\n")
  end
end
