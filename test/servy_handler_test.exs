defmodule ServyHandlerTest do
  use ExUnit.Case
  doctest Servy.Handler

  test "responds 200 to GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "Bears, Lions, Tigers"
  end

  test "responds 200 to GET /bears" do
    request = """
    GET /bears HTTP/1.1
    Host: example.com
    Accept: */*

    """

    response = Servy.Handler.handle(request)

    assert response =~ "<li>Brutus (Grizzly)</li>"
    assert response =~ "<li>Kenai (Grizzly)</li>"
    assert response =~ "<li>Scarface (Grizzly)</li>"
  end

  test "responds 404 to GET /bigfoot" do
    request = """
    GET /bigfoot HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "404 Not Found"
  end

  test "responds 200 to GET /bears/1" do
    request = """
    GET /bears/1 HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "Is Teddy hibernating? <strong>true</strong>"
  end

  test "responds 200 to GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "Bears, Lions, Tigers"
  end

  test "responds 200 to GET /bears with an id query param" do
    request = """
    GET /bears?id=2 HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "Is Smokey hibernating? <strong>false</strong>"
  end

  test "responds 200 to GET /about" do
    request = """
    GET /about HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "<h1>Clark's Wildthings Refuge</h1>"
  end

  test "responds 200 to GET /bears/new" do
    request = """
    GET /bears/new HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "<h1>Create a new bear</h1>"
  end

  test "responds 200 to GET /faq" do
    request = """
    GET /faq HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "Frequently Asked Questions"
  end

  test "responds 200 to GET /contact" do
    request = """
    GET /contact HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "<h1>Contact Us</h1>"
  end

  test "responds 403 to DELETE /bears/{id}" do
    request = """
    DELETE /bears/7 HTTP/1.1
    Host: example.com
    Accept: */*

    """

    assert Servy.Handler.handle(request) =~ "403 Forbidden"
  end

  test "responds 200 to POST /bears" do
    request = """
    POST /bears HTTP/1.1
    Host: example.com
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    name=Wally&type=Polar
    """

    assert Servy.Handler.handle(request) =~ "Wally created!"
  end

  test "responds 200 to GET /api/bears" do
    request = """
    GET /api/bears HTTP/1.1
    Host: example.com
    Accept: */*

    """

    response = Servy.Handler.handle(request)

    assert response =~ "200 OK"
    assert response =~ "content-type: application/json"
    assert response =~ "content-length: 605"
    assert response =~ "[{\"hibernating\":true,\"type\":\"Brown\",\"name\":\"Teddy\",\"id\":1},{\"hibernating\":false,\"type\":\"Black\",\"name\":\"Smokey\",\"id\":2},{\"hibernating\":false,\"type\":\"Brown\",\"name\":\"Paddington\",\"id\":3},{\"hibernating\":true,\"type\":\"Grizzly\",\"name\":\"Scarface\",\"id\":4},{\"hibernating\":false,\"type\":\"Polar\",\"name\":\"Snow\",\"id\":5},{\"hibernating\":false,\"type\":\"Grizzly\",\"name\":\"Brutus\",\"id\":6},{\"hibernating\":true,\"type\":\"Black\",\"name\":\"Rosie\",\"id\":7},{\"hibernating\":false,\"type\":\"Panda\",\"name\":\"Roscoe\",\"id\":8},{\"hibernating\":true,\"type\":\"Polar\",\"name\":\"Iceman\",\"id\":9},{\"hibernating\":false,\"type\":\"Grizzly\",\"name\":\"Kenai\",\"id\":10}]"
  end

  test "responds 200 to POST /api/bears" do
    request = """
    POST /api/bears HTTP/1.1
    Host: example.com
    Accept: */*
    Content-Type: application/json
    Content-Length: 21

    {"name": "Breezly", "type": "Polar"}
    """

    response = Servy.Handler.handle(request)

    assert response =~ "201 Created"
    assert response =~ "content-type: application/json"
    assert response =~ "content-length: 35"
    assert response =~ "Created a Polar bear named Breezly!"
  end

  test "responds 200 to GET /sensors" do
    request = """
    GET /sensors HTTP/1.1
    Host: example.com
    Accept: */*

    """

    response = Servy.Handler.handle(request)

    assert response =~ "200 OK"
    assert response =~ "content-type: text/html"
    assert response =~ "<h1>Sensors</h1>"
    assert response =~ "<h2>Snapshots</h2>"
    assert response =~ "<img src=\"cam-1-snapshot.jpg\""
    assert response =~ "<img src=\"cam-2-snapshot.jpg\""
    assert response =~ "<img src=\"cam-3-snapshot.jpg\""
    assert response =~ "lat: \"29.0469 N\""
    assert response =~ "lng: \"98.8667 W\""
  end
end
