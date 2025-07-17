defmodule Servy.HttpClient do
  alias Servy.HttpResponse

  def get(host, port, request) do
    {:ok, socket} = :gen_tcp.connect(to_charlist(host), port, [:binary, packet: :raw, active: false])
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
