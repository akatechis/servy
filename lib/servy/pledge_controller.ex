defmodule Servy.PledgeController do
  alias Servy.PledgeServer

  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | resp_body: "<p>#{name} pledged #{amount}!</p>", status_code: 201 }
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    %{ conv | resp_body: (inspect pledges), status_code: 200 }
  end
end
