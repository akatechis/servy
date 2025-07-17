defmodule Servy.Handler do
  require Logger
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
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

  defp route(%Conv{method: "GET", path: "/snapshots"} = conv) do
    parent = self()

    spawn(fn ->
      snapshot1 = VideoCam.get_snapshot("cam-1")
      send(parent, {:snapshot, snapshot1})
    end)

    spawn(fn ->
      snapshot2 = VideoCam.get_snapshot("cam-2")
      send(parent, {:snapshot, snapshot2})
    end)

    spawn(fn ->
      snapshot3 = VideoCam.get_snapshot("cam-3")
      send(parent, {:snapshot, snapshot3})
    end)

    snapshot1 = receive do {:snapshot, filename} -> filename end
    snapshot2 = receive do {:snapshot, filename} -> filename end
    snapshot3 = receive do {:snapshot, filename} -> filename end

    %{ conv | status_code: 200, resp_body: inspect([snapshot1, snapshot2, snapshot3]) }
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

  defp route(%Conv{method: "GET", path: "/bears/" <> id} = conv) when id != "new" do
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
    html_path = Path.join(@pages_path, path <> ".html")
    markdown_path = Path.join(@pages_path, path <> ".md")

    markdown_result = try_load_markdown(markdown_path)
    case markdown_result do
      {:ok, body} ->
        %{conv | resp_body: body, status_code: 200}

      {:error, :enoent} ->
        html_result = try_load_html(html_path)
        handle_file(html_result, conv)

      error -> handle_file(error, conv)
    end
  end

  defp try_load_markdown(path) do
    case File.read(path) do
      {:ok, body} ->
        {:ok, Earmark.as_html!(body)}

      {:error, :enoent} ->
        {:error, :enoent}

      {:error, reason} ->
        Logger.error("Error reading file: #{reason}")
        {:error, reason}
    end
  end

  defp try_load_html(path) do
    case File.read(path) do
      {:ok, body} ->
        {:ok, body}

      {:error, :enoent} ->
        {:error, :enoent}

      {:error, reason} ->
        Logger.error("Error reading file: #{reason}")
        {:error, reason}
    end
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
