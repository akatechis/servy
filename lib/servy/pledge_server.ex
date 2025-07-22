defmodule Servy.PledgeServer do

  @server_name :pledge_server

  # Client API

  def start() do
    IO.puts "Starting Pledge Server..."
    pid = spawn(__MODULE__, :listen_loop, [[], 0])
    Process.register(pid, @server_name)
    pid
  end

  def create_pledge(name, amount) do
    send @server_name, {self(), :create_pledge, name, amount}
    receive do
      {:response, id} -> id
    end
  end

  def recent_pledges do
    send @server_name, {self(), :recent_pledges}
    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged do
    send @server_name, {self(), :total_pledged}
    receive do
      {:response, total} -> total
    end
  end

  # Server

  def listen_loop(state, total_pledged) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        new_state = [ {name, amount} | Enum.take(state, 2) ]

        send sender, {:response, id}
        listen_loop(new_state, total_pledged + amount)
      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state, total_pledged)
      {sender, :total_pledged} ->
        send sender, {:response, total_pledged}
      unexpected ->
        IO.puts "Unexpected message: #{inspect(unexpected)}"
        listen_loop(state, total_pledged)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # Simulate sending pledge to an external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end

# alias Servy.PledgeServer

# Servy.PledgeServer.start()

# IO.inspect PledgeServer.create_pledge("larry", 10)
# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("curly", 30)
# IO.inspect PledgeServer.create_pledge("daisy", 40)
# IO.inspect PledgeServer.create_pledge("grace", 50)

# IO.inspect PledgeServer.recent_pledges(), label: "Recent Pledges"
# IO.inspect PledgeServer.total_pledged(), label: "Total Pledged"
