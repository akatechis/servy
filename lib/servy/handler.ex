defmodule Servy.Handler do
  require Logger
  alias Servy.Conv
  alias Servy.BearController
  import Servy.Plugins

  @pages_path Path.expand("../../pages", __DIR__)

  def handle(request) do
    request
    |> Conv.parse()
    |> rewrite_path
    |> log
    |> route
    |> track
    |> Conv.format_response()
  end

  defp route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status_code: 200}
  end

  defp route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  defp route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  defp route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv)
  end

  defp route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    Path.join(@pages_path, "bears/new.html")
    |> File.read()
    |> case do
      {:ok, form} ->
        %{conv | resp_body: form, status_code: 200}

      {:error, :enoent} ->
        Logger.error("File not found")
        %{conv | resp_body: "File not found", status_code: 404}

      {:error, reason} ->
        Logger.error("Error reading file: #{reason}")
        %{conv | resp_body: "Server Error #{reason}", status_code: 500}
    end
  end

  defp route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    bear_params = Map.put(conv.request_body, "id", id)
    BearController.show(conv, bear_params)
  end

  defp route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv)
  end

  defp route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.request_body)
  end

  defp route(%Conv{method: "GET", path: path} = conv) do
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
