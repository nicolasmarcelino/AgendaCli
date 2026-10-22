defmodule Agenda.Store do
  @file_path "contacts.json"

  def load do
    case File.read(@file_path) do
      {:ok, content} ->
        content
        |> Jason.decode!()
        |> Enum.map(fn t ->
          %{
            id: t["id"],
            name: t["name"],
            company: t["company"],
            phone: t["phone"],
            email: t["email"]
          }
        end)

      {:error, _} ->
        []
    end
  end

  def save(todos) do
    todos
    |> Jason.encode!(pretty: true)
    |> then(&File.write!(@file_path, &1))
  end
end
