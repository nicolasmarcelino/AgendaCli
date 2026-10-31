defmodule Agendacli.Contacts do
  use GenServer
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def addItem(name, company, phone, email) do
    GenServer.cast(__MODULE__, {:addItem, name, company, phone, email})
  end

  def del(id) do
    GenServer.cast(__MODULE__, {:del, id})
  end

  def show(id) do
    GenServer.call(__MODULE__, {:show, id})
  end

  def search(param, dado) do
    GenServer.call(__MODULE__, {:search, param, dado})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def edit(id, field, new_value) do
    GenServer.cast(__MODULE__, {:edit, id, field, new_value})
  end


  def init(:ok) do
    state = AgendaCli.Store.load
    {:ok, state}
  end

  def handle_cast({:addItem, name, company, phone, email}, state) do
    item = %{id: new_id(), name: name, company: company, phone: phone, email: email}
    new_state = state ++ [item]
    AgendaCli.Store.save(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:del, id}, state) do
    new_state = Enum.reject(state, fn c -> c.id === id end)
    AgendaCli.Store.save(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:edit, id, field, new_value}, state) do
    new_state =
      Enum.map(state, fn c ->
        if c.id == id do
          Map.put(c, field, new_value)
        else
          c
        end
      end)

    {:noreply, new_state}
  end

  def handle_call({:show, id}, _from, state) do
    {:reply, Enum.find(state, fn c -> c.id == id end), state}
  end

  def handle_call({:search, param, dado}, _from, state) do
    case param do
      :name ->
        retorno = Enum.filter(state, fn c -> String.contains?(
          String.downcase(c.name),
          String.downcase(dado))
        end)
        {:reply, retorno, state}
      :company ->
        retorno = Enum.filter(state, fn c -> String.contains?(
          String.downcase(c.company),
          String.downcase(dado))
        end)
        {:reply, retorno, state}
      :phone ->
        retorno = Enum.filter(state, fn c -> String.contains?(
          c.phone,
          dado)
        end)
        {:reply, retorno, state}
      :email ->
        retorno = Enum.filter(state, fn c -> String.contains?(
          c.email,
          dado)
        end)
        {:reply, retorno, state}
      _ ->
        {:reply, state, state}
    end
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  defp new_id do
    :os.system_time(:millisecond)
  end
end
