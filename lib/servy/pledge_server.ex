defmodule Servy.PledgeServer do
  use GenServer
  @server_name :pledge_server
  @initial_state {[], 0}

  # Client API

  def start_link() do
    IO.puts "Starting Pledge Server..."
    GenServer.start_link(__MODULE__, @initial_state, name: @server_name)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def create_pledge(name, amount) do
    GenServer.call(@server_name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@server_name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@server_name, :total_pledged)
  end

  def clear do
    GenServer.cast(@server_name, :clear)
  end

  def handle_cast(:clear, _state) do
    {:noreply, {[], 0}}
  end

  def handle_call({:create_pledge, name, amount}, _from, {pledges, total_pledged}) do
    {:ok, id} = send_pledge_to_service(name, amount)

    new_pledges = [ {name, amount} | Enum.take(pledges, 2) ]
    new_total = total_pledged + amount

    {:reply, id, {new_pledges, new_total} }
  end

  def handle_call(:recent_pledges, _from, {pledges, total_pledged}) do
    {:reply, pledges, {pledges, total_pledged} }
  end

  def handle_call(:total_pledged, _from, {pledges, total_pledged}) do
    {:reply, total_pledged, {pledges, total_pledged} }
  end

  defp send_pledge_to_service(_name, _amount) do
    # Simulate sending pledge to an external service
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end
