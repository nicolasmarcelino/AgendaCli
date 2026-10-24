defmodule Agenda do

  use GenServer

  # --- API pública
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

  def add(name) do
    GenServer.cast(__MODULE__, {:add, name})
  end

  def search(param, dado) do
    GenServer.call(__MODULE__, {:search, param, dado})
  end



  def mark_done(id) do
    GenServer.cast(__MODULE__, {:mark_done, id})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end


  # --- Callbacks do GenServer
  def init(:ok) do
    state = Agenda.Store.load
    {:ok, state}
  end

  def handle_cast({:addItem, name, company, phone, email}, state) do
    item = %{id: new_id(), name: name, company: company, phone: phone, email: email}
    new_state = state ++ [item]
    Agenda.Store.save(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:del, id}, state) do
    new_state = Enum.reject(state, fn c -> c.id === id end)
    Agenda.Store.save(new_state)
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

    #retorno =
    #Enum.filter(state, fn c -> c |> Map.get(param) |> String.downcase() |> String.contains?#(dado) end)

    #{:reply, retorno, state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  defp new_id do
    :os.system_time(:millisecond)
  end

end
