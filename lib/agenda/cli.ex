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
      {:search, param, dado} ->
        IO.inspect(Agenda.search(param, dado))
        loop()
      {:del, id} ->
        Agenda.del(id)
        loop()
      {:show, id} ->
        c = Agenda.show(id)
        IO.puts("""

          [#{c.id}]
          Name: #{c.name}
          Company: #{c.company}
          Phone: #{c.phone}
          E-mail: #{c.email}
          """)
        loop()
      :list ->
        contatos = Agenda.list()
        Enum.each(contatos, fn c ->
          IO.puts("""

          [#{c.id}]
          Name: #{c.name}
          Company: #{c.company}
          Phone: #{c.phone}
          E-mail: #{c.email}
          """)
        end)
        loop()
        :exit ->
          IO.puts("Até mais!")
        :unknown ->
          IO.puts("Comando inválido, tente novamente.")
          loop()
    end
  end

  def parse_search("--email " <> dado) do
    {:search, :company, dado}
  end

  def parse_search("--number " <> dado) do
    {:search, :company, dado}
  end

  def parse_search("--company " <> dado) do
    {:search, :company, dado}
  end

  def parse_search("--name " <> dado) do
    {:search, :name, dado}
  end

  def parse_add(infos) do
    case String.split(infos, ["--name ", " --company ", " --phone ", " --email "], trim: true) do
      [name, company, phone, email] ->
        {:addItem, name, company, phone, email}
      _ ->
        :unknown
    end
  end

  def parse("add " <> infos) do
    parse_add(infos)
  end

  def parse("search " <> params) do
    parse_search(params)
  end

  def parse("del " <> id) do
    {:del, parse_id(id)}
  end

  def parse("show " <> id) do
    {:show, parse_id(id)}
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
