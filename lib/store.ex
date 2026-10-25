defmodule AgendaCli.Store do
  @file_path "contacts.json"

  def load do
    case File.read(@file_path) do
      {:ok, file} ->
        file
        |> Jason.decode!()
        |> Enum.map(fn c ->
          %{
            id: c["id"],
            name: c["name"],
            company: c["company"],
            phone: c["phone"],
            email: c["email"]
          }
        end)

      {:error, _} ->
        []
    end
  end

  def save(contacts) do
    contacts
    |> Jason.encode!(pretty: true)
    |> then(&File.write!(@file_path, &1))
  end
end
