defmodule ConvTest do
  use ExUnit.Case
  doctest Servy.Conv

  test "properly parses request body" do
    request_body = "name=Baloo&type=Brown"
    parsed_body = Servy.Conv.parse_request_body("application/x-www-form-urlencoded", request_body)
    assert parsed_body == %{"name" => "Baloo", "type" => "Brown"}
  end

  test "properly formats header map" do
    headers = %{
      "content-type" => "text/html",
      "content-length" => "123",
      "x-framework" => "servy",
      "x-powered-by" => "Elixir",
      "x-custom-header" => "CustomValue"
    }

    formatted_headers = Servy.Conv.format_headers(%Servy.Conv{resp_headers: headers, resp_body: "<html></html>"})

    assert formatted_headers =~ "content-type: text/html"
    assert formatted_headers =~ "content-length: 13"
    assert formatted_headers =~ "x-framework: servy"
    assert formatted_headers =~ "x-powered-by: Elixir"
    assert formatted_headers =~ "x-custom-header: CustomValue"
  end
end
