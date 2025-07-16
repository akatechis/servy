defmodule Servy.HttpUtils do
  def parse_header_lines(header_lines) do
    Enum.reduce(header_lines, %{}, fn header_line, headers ->
      [key, value] = header_line |> String.split(":", parts: 2)
      Map.put(headers, String.downcase(key), String.trim(value))
    end)
  end
end
