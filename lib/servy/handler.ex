defmodule Servy.Handler do
  require Logger
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.PledgeController
  alias Servy.View
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

  defp route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Servy.PageNotFoundCounter.get_counts()
    %{conv | resp_body: inspect(counts), status_code: 200}
  end

  defp route(%Conv{method: "POST", path: "/pledges"} = conv) do
    PledgeController.create(conv, conv.request_body)
  end

  defp route(%Conv{method: "GET", path: "/pledges"} = conv) do
    PledgeController.index(conv)
  end

  defp route(%Conv{method: "GET", path: "/sensors"} = conv) do
    {snapshots, bigfoot_location} = Servy.SensorServer.get_sensor_data()
    location = inspect(bigfoot_location) |> String.replace("%", "")
    View.render_template(conv, "sensors.eex", 200, snapshots: snapshots, location: location)
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

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp try_load_html(path) do
    case File.read(path) do
      {:ok, body} ->
        {:ok, body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp handle_file({:ok, body}, conv) do
    new_headers = Map.put(conv.resp_headers, "content-type", "text/html")
    %{conv | resp_body: body, status_code: 200, resp_headers: new_headers}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | resp_body: "File not found", status_code: 404}
  end

  defp handle_file({:error, reason}, conv) do
    Logger.error("Error reading file: #{reason}")
    %{conv | resp_body: "File not found", status_code: 500}
  end
end
