defmodule Servy.PageNotFoundCounter do

  @initial_counts %{}

  def start do
    pid = spawn(__MODULE__, :loop, [@initial_counts])
    Process.register(pid, __MODULE__)
    pid
  end

  # Client API

  def bump_count(path) do
    send(__MODULE__, {self(), :bump_count, path})
    receive do
      { :response } -> :ok
    end
  end

  def get_count(path) do
    send(__MODULE__, {self(), :get_count, path})
    receive do
      { :response, count } -> count
    end
  end

  def get_counts do
    send(__MODULE__, {self(), :get_counts})
    receive do
      { :response, counts } -> counts
    end
  end

  # Server API

  def loop(counts) do
    receive do
      {sender, :bump_count, path} ->
        new_counts = Map.update(counts, path, 1, fn (count) -> count + 1 end)
        send sender, { :response }
        IO.inspect(new_counts, label: "Counts")
        loop(new_counts)

      {sender, :get_count, path} ->
        count = Map.get(counts, path, 0)
        send(sender, { :response, count })
        loop(counts)

      {sender, :get_counts} ->
        send(sender, { :response, counts})
        loop(counts)

      unknown_message ->
        IO.puts("Unknown message: #{inspect(unknown_message)}")
        loop(counts)
    end
  end

end
