defmodule Servy.Api.BearController do
  def index(%Servy.Conv{} = conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    %{conv | resp_body: json, status_code: 200, resp_headers: %{"content-type" => "application/json"}}
  end

end
