defmodule Servy.Plugins do
  require Logger

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/#{id}"}
  end

  def rewrite_path(conv), do: conv

  def log(conv) do
    Logger.info(conv)
    conv
  end

  def track(%{path: path, status_code: 404} = conv) do
    Logger.warning("[Warning] #{path} is on the loose!")
    conv
  end

  def track(conv), do: conv

end
