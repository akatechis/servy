defmodule Timer do
  def remind(message, seconds) do
    spawn(Timer, :do_task, [message, seconds])
  end

  def do_task(message, seconds) do
    :timer.sleep(seconds * 1000)
    IO.puts("⏰ Reminder: #{message}")
  end

  def block_on_pids([pid | pids]) do
    :timer.sleep(300)
    if Process.alive?(pid) do
      block_on_pids([pid | pids])
    else
      block_on_pids(pids)
    end
  end

  def block_on_pids([]), do: :ok

  def example do
    pid1 = Timer.remind("Stand up", 5)
    pid2 = Timer.remind("Sit down", 10)
    pid3 = Timer.remind("Fight, Fight, Fight", 15)
    block_on_pids([pid1, pid2, pid3])
  end
end

# Timer.example()
