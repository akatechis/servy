defmodule Servy.Conv do
  defstruct method: "", path: "", resp_body: "", status_code: nil

  def parse(request) do
    [top, request_body] = request |> String.split("\n\n")
    [request_line | header_lines] = top |> String.split("\n")
    [method, path, _] = request_line |> String.split(" ")

    headers = parse_headers(header_lines)
    %Servy.Conv{method: method, path: path, status_code: nil, resp_body: ""}
  end

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn header_line, acc ->
      [key, value] = header_line |> String.split(": ", parts: 2)
      Map.put(acc, String.downcase(key), value)
    end)
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{full_status(conv)}
    Context-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  def full_status(%Servy.Conv{} = conv) do
    "#{conv.status_code} #{reason_phrase(conv.status_code)}"
  end

  def reason_phrase(200), do: "OK"
  def reason_phrase(201), do: "Created"
  def reason_phrase(401), do: "Unauthorized"
  def reason_phrase(403), do: "Forbidden"
  def reason_phrase(404), do: "Not Found"
  def reason_phrase(500), do: "Internal Server Error"
  def reason_phrase(_SC), do: "Unknown Status"

end
