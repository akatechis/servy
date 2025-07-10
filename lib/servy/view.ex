defmodule Servy.View do
  @moduledoc """
  A module for rendering views.
  """

  alias Servy.Conv
  require EEx

  @templates_path Path.expand("../../templates", __DIR__)

  def render_template(%Conv{} = conv, template, code \\ 200, bindings \\ []) do
    html_content = EEx.eval_file(
      Path.join(@templates_path, template),
      bindings
    )
    %{conv | resp_body: html_content, status_code: code, resp_headers: %{"content-type": "text/html"}}
  end

  def render_json(%Conv{} = conv, code \\ 200, data) do
    json_content = Poison.encode!(data)
    %{conv | resp_body: json_content, status_code: code, resp_headers: %{"content-type": "application/json"}}
  end
end
