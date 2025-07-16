defmodule ServyHttpUtilsTest do
  use ExUnit.Case
  doctest Servy.HttpUtils

  test "properly parses headers" do
    headers_lines = [
      "Host: example.com",
      "User-Agent: ServyClient/1.0",
      "Accept: */*",
      "Content-Type: application/x-www-form-urlencoded",
      "Content-Length: 21"
    ]

    headers = Servy.HttpUtils.parse_header_lines(headers_lines)
    assert map_size(headers) == 5
    assert headers["host"] == "example.com"
    assert headers["user-agent"] == "ServyClient/1.0"
    assert headers["accept"] == "*/*"
    assert headers["content-type"] == "application/x-www-form-urlencoded"
    assert headers["content-length"] == "21"
  end
end
