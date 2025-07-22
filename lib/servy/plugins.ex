defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv
  alias Servy.PageNotFoundCounter

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    Logger.info(conv)
    conv
  end

  def track(%Conv{path: path, status_code: 404} = conv) do
    PageNotFoundCounter.bump_count(path)
    conv
  end

  def track(conv), do: conv
end
