defmodule Servy.Kickstarter do
  use GenServer

  def start_link(_arg) do
    IO.puts("Starting HTTP Kickstarter...")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = start_server()
    {:ok, server_pid}
  end

  # Client API

  def get_server_pid do
    GenServer.call(__MODULE__, :get_server_pid)
  end

  # Server API

  def handle_call(:get_server_pid, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HTTP server exited (#{inspect(reason)}). Restarting...")
    server_pid = start_server()
    {:noreply, server_pid}
  end

  defp start_server do
    IO.puts("Starting HTTP server...")
    port = Application.get_env(:servy, :port, 4000)
    server_pid = spawn_link(Servy.HttpServer, :start_server, [port])
    Process.register(server_pid, :http_server)
    server_pid
  end

end
