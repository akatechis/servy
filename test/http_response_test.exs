defmodule ServyHttpResponseTest do
  use ExUnit.Case
  doctest Servy.HttpResponse

  test "can parse a response containing HTML" do
    raw = """
    HTTP/1.1 200 OK
    Content-Type: text/html; charset=utf-8
    Host: http://localhost:4000

    <html>
    <body>
      <h1>Welcome to Servy!</h1>
      <p>This is a test response.</p>
    </body>
    </html>
    """

    response = Servy.HttpResponse.parse_response(raw)

    assert response.is_ok
    assert response.status_code == 200
    assert response.http_version == "HTTP/1.1"
    assert response.reason_phrase == "OK"
    assert response.headers["host"] == "http://localhost:4000"
    assert response.headers["content-type"] == "text/html; charset=utf-8"
    assert response.body =~ "<h1>Welcome to Servy!</h1>"
    assert response.body =~ "<p>This is a test response.</p>"
    assert response.body_json == nil
  end

end
