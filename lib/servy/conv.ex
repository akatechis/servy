defmodule Servy.Conv do
  defstruct method: "", path: "", resp_body: "", status_code: nil, request_body: nil, request_headers: nil, resp_headers: %{}

  alias Poison.Parser

  def parse(request) do
    line_sep = String.match?(request, ~r/\r\n/) && "\r\n" || "\n"
    [top, request_body] = request |> String.split(String.duplicate(line_sep, 2), parts: 2)
    [request_line | header_lines] = top |> String.split(line_sep)
    [method, path, _] = request_line |> String.split(" ")

    headers = Servy.HttpUtils.parse_header_lines(header_lines)
    request_body = parse_request_body(headers["content-type"], request_body)

    %Servy.Conv{
      method: method,
      path: path,
      status_code: nil,
      request_headers: headers,
      request_body: request_body,
      resp_headers: %{
        "content-type" => "text/html"
      },
      resp_body: ""
    }
  end

  def parse_request_body("application/x-www-form-urlencoded", request_body) do
    request_body |> URI.decode_query()
  end

  def parse_request_body("application/json", request_body) do
    request_body |> Parser.parse!(%{})
  end

  def parse_request_body(_, _), do: %{}

  def format_response(conv) do
    # Lots of nonsense here, but I really don't like \r\n, and I need to remove them
    # BEFORE calculating the content-length, or clients choke for some reason.

    clean_resp_body = String.replace(conv.resp_body, "\r", "")
    conv = Map.put(conv, :resp_body, clean_resp_body)

    formatted_headers = format_headers(conv)

    resp_text ="""
    HTTP/1.1 #{full_status(conv)}
    #{formatted_headers}

    #{conv.resp_body}
    """

    String.replace(resp_text, "\r", "")
  end

  def full_status(%Servy.Conv{} = conv) do
    "#{conv.status_code} #{reason_phrase(conv.status_code)}"
  end

  def format_headers(%Servy.Conv{resp_headers: resp_headers} = conv) do
    resp_headers
    |> Map.put("content-length", byte_size(conv.resp_body))
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
    |> Enum.join("\n")
  end

  def reason_phrase(200), do: "OK"
  def reason_phrase(201), do: "Created"
  def reason_phrase(204), do: "No Content"
  def reason_phrase(301), do: "Moved Permanently"
  def reason_phrase(304), do: "Not Modified"
  def reason_phrase(400), do: "Bad Request"
  def reason_phrase(401), do: "Unauthorized"
  def reason_phrase(403), do: "Forbidden"
  def reason_phrase(404), do: "Not Found"
  def reason_phrase(405), do: "Method Not Allowed"
  def reason_phrase(409), do: "Conflict"
  def reason_phrase(429), do: "Too Many Requests"
  def reason_phrase(code) when code >= 400 and code < 500, do: "Bad Request"
  def reason_phrase(code) when code >= 500, do: "Internal Server Error"
  def reason_phrase(_), do: "Unknown"
end
