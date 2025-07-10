defmodule Servy.Bear do
  @derive [Poison.Encoder]
  defstruct id: nil, name: "", type: "", hibernating: false

  def order_asc_by_name(a, b) do
    a.name <= b.name
  end

  def bear_is_grizzly(bear) do
    bear.type == "Grizzly"
  end
end
