defmodule Servy.Recurse do
  def triple([head | tail]) do
    Servy.Recurse.map([head | tail], fn x -> x * 3 end)
  end

  def map([head | tail], func) do
    [func.(head) | map(tail, func)]
  end

  def map([], _func) do
    []
  end
end

triples = Servy.Recurse.triple([1, 2, 3, 5, 10])
IO.inspect(triples, label: "Triples")
