defmodule Agenda.CLI do

  def main(_args) do
    Agenda.start_link()
    loop()
  end

  def loop do
    input = IO.gets("agenda> ") |> String.trim()
    case parse(input) do
      {:addItem, name, company, phone, email} ->
        Agenda.addItem(name, company, phone, email)
        loop()
      {:del, id} ->
        Agenda.del(id)
        IO.puts("   Tarefa ##{id} removida.")
        loop()
      {:done, id} ->
        Agenda.mark_done(id)
        IO.puts("   Tarefa ##{id} marcada como concluída")
        loop()
      :list ->
        todos = Agenda.list()
        if Enum.empty?(todos) do
          IO.puts("   Nenhuma tarefa cadastrada.")
        else
          IO.puts("---------------------------------------------")
          Enum.each(todos, fn t ->
            status = if t.done, do: "[OK]", else: "[  ]"
            IO.puts("   #{status} ##{t.id} - #{t.name}")
          end)
          IO.puts("---------------------------------------------")
        end
        loop()
        :exit ->
          IO.puts("Até mais!")
        :unknown ->
          IO.puts("Comando inválido, tente novamente.")
          loop()
    end
  end

  #def parse("add -- name " <> name <> " --company " <> company <> " --phone " <> phone <> #"  --email" <> email) do
  #  {:addItem, name, company, phone, email}
  #end

  def parse_add(infos) do
    case String.split(infos, ["--name ", " --company ", " --phone ", " --email "]) do
      ["", name, company, phone, email] ->
        {:addItem, name, company, phone, email}
      _ ->
        :unknown
    end
  end

  def parse("add " <> infos) do
    parse_add(infos)
  end

  def parse("del " <> id) do
    {:del, parse_id(id)}
  end

  def parse("done " <> id) do
    {:done, parse_id(id)}
  end

  def parse("list") do
    :list
  end

  def parse("exit") do
    :exit
  end

  def parse(_) do
    :unknown
  end

  defp parse_id(str) do
    str |> String.trim |> String.to_integer
  end

end
