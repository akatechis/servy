defmodule Servy.Http do

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, status_code: nil, resp_body: ""}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status_code} #{reason_phrase(conv.status_code)}
    Context-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  def reason_phrase(200), do: "OK"
  def reason_phrase(201), do: "Created"
  def reason_phrase(401), do: "Unauthorized"
  def reason_phrase(403), do: "Forbidden"
  def reason_phrase(404), do: "Not Found"
  def reason_phrase(500), do: "Internal Server Error"
  def reason_phrase(_SC), do: "Unknown Status"

end
