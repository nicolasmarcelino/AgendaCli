defmodule Agenda do

  use GenServer

  # --- API pública
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def addItem(name, company, phone, email) do
    GenServer.cast(__MODULE__, {:addItem, name, company, phone, email})
  end

  def add(name) do
    GenServer.cast(__MODULE__, {:add, name})
  end



  def del(id) do
    GenServer.cast(__MODULE__, {:del, id})
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

  def handle_cast({:add, name}, state) do
    task = %{id: new_id(), name: name, done: false}
    new_state = state ++ [task]
    Agenda.Store.save(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:del, id}, state) do
    new_state = Enum.reject(state, fn t -> t.id === id end)
    Agenda.Store.save(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:mark_done, id}, state) do
    new_state = Enum.map(state, fn t ->
      if t.id == id do
        %{ t | done: true}
      else
        t
      end
    end)
    Agenda.Store.save(new_state)
    {:noreply, new_state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  defp new_id do
    :os.system_time(:millisecond)
  end

end
