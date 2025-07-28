defmodule Servy.PageNotFoundCounter do
  use GenServer

  @initial_counts %{}

  def start_link do
    GenServer.start_link(__MODULE__, @initial_counts, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  # Client API

  def bump_count(path) do
    GenServer.call(__MODULE__, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(__MODULE__, {:get_count, path})
  end

  def get_counts do
    GenServer.call(__MODULE__, :get_counts)
  end

  # Server API

  def handle_call({:bump_count, path}, _from, counts) do
    new_counts = Map.update(counts, path, 1, fn (count) -> count + 1 end)
    {:reply, :ok, new_counts}
  end

  def handle_call({:get_count, path}, _from, counts) do
    count = Map.get(counts, path, 0)
    {:reply, count, counts}
  end

  def handle_call(:get_counts, _from, counts) do
    {:reply, counts, counts}
  end

end
