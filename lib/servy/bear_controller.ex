defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.View

  def index(%Conv{} = conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    View.render_template(conv, "index.eex", 200, bears: bears)
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    View.render_template(conv, "show.eex", 200, bear: bear)
  end

  def create(%Conv{} = conv, bear) do
    View.render_template(conv, "bear_created.eex", 201, bear: bear)
  end

  def delete(%Conv{} = conv) do
    View.render_template(conv, "bear_deleted.eex", 403)
  end
end
