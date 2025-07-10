defmodule Servy.Wildthings do
  alias Servy.Bear

  @db_path Path.expand("../../db", __DIR__)

  def list_bears do
    {:ok, json} = File.read(Path.join(@db_path, "bears.json"))
    store = Poison.decode!(json, as: %{"bears" => [%Bear{}]})
    store["bears"]
  end

  def get_bear(id) when is_integer(id) do
    list_bears()
    |> Enum.find(fn bear -> bear.id == id end)
    |> case do
      nil -> %Bear{id: id, name: "Unknown Bear", type: "Unknown"}
      bear -> bear
    end
  end

  def get_bear(id) when is_binary(id) do
    id
    |> String.to_integer()
    |> get_bear()
  end
end
