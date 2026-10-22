defmodule Agenda.CLI do

  def main(_args) do
    Agenda.start_link()
    loop()
  end

  def loop do
    input = IO.gets("agenda> ") |> String.trim()
    case parse(input) do
      {:add, name} ->
        Agenda.add(name)
        IO.puts("   Tarefa \"#{name}\" cadastrada com sucesso.")
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


  def parse("add " <> name) do
    {:add, name}
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
