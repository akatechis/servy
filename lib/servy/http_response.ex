defmodule Servy.HttpResponse do
  defstruct [is_ok: false, status_code: 0, reason_phrase: "", http_version: "", headers: %{}, body: nil, body_json: nil]

  alias Poison.Parser

  defp parse_json_body(body, content_type) do
    if content_type == "application/json" do
      Parser.parse!(body)
    else
      nil
    end
  end

  def parse_response(response) do
    line_sep = String.match?(response, ~r/\r\n/) && "\r\n" || "\n"
    [top, response_body] = response |> String.split(String.duplicate(line_sep, 2), parts: 2)
    [result_line | header_lines] = top |> String.split(line_sep)
    [version, status_code, reason_phrase] = result_line |> String.split(" ")

    headers = Servy.HttpUtils.parse_header_lines(header_lines)
    status_code = String.to_integer(status_code)

    %Servy.HttpResponse{
      is_ok: status_code >= 200 and status_code < 400,
      status_code: status_code,
      http_version: version,
      reason_phrase: reason_phrase,
      headers: headers,
      body: response_body,
      body_json: parse_json_body(response_body, headers["content-type"])
    }
  end
end
