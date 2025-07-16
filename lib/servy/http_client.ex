defmodule Servy.HttpClient do
  alias Servy.HttpResponse

  def get(request) do
    host = to_charlist("localhost")
    {:ok, socket} = :gen_tcp.connect(host, 4000, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(socket, request)

    case :gen_tcp.recv(socket, 0) do
      {:ok, response} ->
        :gen_tcp.close(socket)
        {:ok, HttpResponse.parse_response(response)}
      {:error, reason} ->
        :gen_tcp.close(socket)
        {:error, reason}
    end
  end
end
