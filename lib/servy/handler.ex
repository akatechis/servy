defmodule Servy.Handler do
  require Logger

  @pages_path Path.expand("../../pages", __DIR__)

  def handle(request) do
    request
    |> Servy.Http.parse
    |> Servy.Plugins.rewrite_path
    |> Servy.Plugins.log
    |> route
    |> Servy.Plugins.track
    |> Servy.Http.format_response
  end

  defp route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status_code: 200}
  end

  defp route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status_code: 200}
  end

  defp route(%{method: "GET", path: "/bears/new"} = conv) do
    Path.join(@pages_path, "bears/new.html")
    |> File.read()
    |> case do
      {:ok, form} ->
        %{ conv | resp_body: form, status_code: 200 }
      {:error, :enoent} ->
        Logger.error("File not found")
        %{ conv | resp_body: "File not found", status_code: 404 }
      {:error, reason} ->
        Logger.error("Error reading file: #{reason}")
        %{ conv | resp_body: "Server Error #{reason}", status_code: 500 }
    end
  end

  defp route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Bear #{id}", status_code: 200}
  end

  defp route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{conv | resp_body: "Bears must never be deleted!", status_code: 403}
  end

  defp route(%{method: "GET", path: path} = conv) do
    @pages_path
    |> Path.join("#{path}.html")
    |> File.read()
    |> handle_file(conv)
  end

  defp handle_file({:ok, body}, conv) do
    %{conv | resp_body: body, status_code: 200}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | resp_body: "File not found", status_code: 404}
  end

  defp handle_file({:error, reason}, conv) do
    Logger.error("Error reading file: #{reason}")
    %{conv | resp_body: "File not found", status_code: 500}
  end
end
