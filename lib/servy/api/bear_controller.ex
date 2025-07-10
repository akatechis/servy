defmodule Servy.Api.BearController do
  alias Servy.Conv

  def index(%Conv{} = conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    %{conv | resp_body: json, status_code: 200, resp_headers: %{"content-type" => "application/json"}}
  end

  def create(%Conv{} = conv) do
    %{"name" => name, "type" => type} = conv.request_body

    # Here you would typically save the bear to a database or in-memory store
    # For simplicity, we just return a success message
    response_body = "Created a #{type} bear named #{name}!"

    %{conv | resp_body: response_body, status_code: 201, resp_headers: %{"content-type" => "application/json"}}
  end
end
