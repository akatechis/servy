defmodule ServyHandlerTest do
  use ExUnit.Case
  doctest Servy.Handler

  test "responds 200 to GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "Bears, Lions, Tigers"
  end

  test "responds 200 to GET /bears" do
    request = """
    GET /bears HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "Teddy, Smokey, Paddington"
  end

  test "responds 404 to GET /bigfoot" do
    request = """
    GET /bigfoot HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "404 Not Found"
  end

  test "responds 200 to GET /bears/1" do
    request = """
    GET /bears/1 HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "Bear 1"
  end

  test "responds 200 to GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "Bears, Lions, Tigers"
  end

  test "responds 200 to GET /bears with an id query param" do
    request = """
    GET /bears?id=2 HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "Bear 2"
  end

  test "responds 200 to GET /about" do
    request = """
    GET /about HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "<h1>Clark's Wildthings Refuge</h1>"
  end

  test "responds 200 to GET /bears/new" do
    request = """
    GET /bears/new HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "<h1>Create a new bear</h1>"
  end

  test "responds 200 to GET /faq" do
    request = """
    GET /faq HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "<h1>FAQ</h1>"
  end

  test "responds 200 to GET /contact" do
    request = """
    GET /contact HTTP/1.1
    Host: example.com
    User-Agent: ServyClient/1.0
    Accept: */*

    """
    assert Servy.Handler.handle(request) =~ "<h1>Contact Us</h1>"
  end
end
