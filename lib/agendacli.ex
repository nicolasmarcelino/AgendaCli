defmodule Agendacli do
  def main do
    IO.puts("""
    --------------------------------------------
    Agenda CLI
    --------------------------------------------
    [add --name <nome> --company <empresa> --phone <telefone> --email <e-mail>]
    Adicionar contato

    [edit --<campo> dado_atualizado]
    Editar informação de um contato

    [list]
    Listar contatos

    [show <id>]
    Listar informação de um contato

    [search --<campo> <pesquisa>]
    Pesquisa em contatos

    [del <id>]
    Exclui contato

    [exit]
    Encerra aplicação.
    --------------------------------------------

    """)
    Agendacli.Contacts.start_link
    loop()
  end

  def loop do
    input = IO.gets("agenda> ") |> String.trim()
    case parse(input) do
      {:addItem, name, company, phone, email} ->
        Agendacli.Contacts.addItem(name, company, phone, email)
        loop()
      {:search, param, dado} ->
        IO.inspect(Agendacli.Contacts.search(param, dado))
        loop()
      {:del, id} ->
        Agendacli.Contacts.del(id)
        loop()
      {:edit, id, field, novo_valor} ->
        Agendacli.Contacts.edit(id, field, novo_valor)
        loop()
      {:show, id} ->
        c = Agendacli.Contacts.show(id)
        IO.puts("""

          [#{c.id}]
          Name: #{c.name}
          Company: #{c.company}
          Phone: #{c.phone}
          E-mail: #{c.email}
          """)
        loop()
      :list ->
        contatos = Agendacli.Contacts.list()
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
          IO.puts("Fechando aplicação.")
        :unknown ->
          IO.puts("Comando inválido, tente novamente.")
          loop()
    end
  end

  def parse_edit([id, "--email", new_value]) do
    {:edit,
    parse_id(id),
    :email,
    new_value}
  end

  def parse_edit([id, "--phone", new_value]) do
    {:edit,
    parse_id(id),
    :phone,
    new_value}
  end

  def parse_edit([id, "--company", new_value]) do
    {:edit,
    parse_id(id),
    :company,
    new_value}
  end

  def parse_edit([id, "--name", new_value]) do
    {:edit,
    parse_id(id),
    :name,
    new_value}
  end

  def parse_search("--email " <> dado) do
    {:search, :email, dado}
  end

  def parse_search("--phone " <> dado) do
    {:search, :phone, dado}
  end

  def parse_search("--company " <> dado) do
    {:search, :company, dado}
  end

  def parse_search("--name " <> dado) do
    {:search, :name, dado}
  end

  def parse_search("--" <> _) do
    IO.puts("Parâmetros válidos: --name, --company, --phone e --email.")
    :unknown
  end

  def parse_search(_) do
    :unknown
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

  def parse("edit " <> rest) do
    case String.split(rest, " ", parts: 3) do
      [id, flag, new_value] -> parse_edit([id, flag, new_value])
      _ -> :unknown
    end
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
