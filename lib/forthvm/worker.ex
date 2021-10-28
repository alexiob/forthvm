defmodule ForthVM.Worker do
  @moduledoc """
  Core supervised worker
  """
  use GenServer

  @tick_interval 10

  def start_link([id: id] = state) do
    id = id || System.unique_integer()
    io = Keyword.get(state, :io, :stdio)

    GenServer.start_link(__MODULE__, [id: id, io: io], name: via_tuple(id))
  end

  def via_tuple(id) do
    {:via, Registry, {ForthVM.Registry, ForthVM.Core.core_id(id), ForthVM.Core}}
  end

  @impl true
  def init(id: id, io: io) do
    case Registry.lookup(ForthVM.Registry, ForthVM.IOCapture) do
      [{io_capture_pid, _}] ->
        # we want to capture all IO and send it to interested subscribers
        Process.group_leader(self(), io_capture_pid)

      _ ->
        nil
    end

    # schedule processing
    tick()

    {:ok, ForthVM.Core.new(id, io)}
  end

  # ---------------------------------------------
  # API
  # ---------------------------------------------

  def execute(pid, process_id, source, dictionary \\ nil) do
    GenServer.call(pid, {:execute, process_id, source, dictionary})
  end

  def spawn(pid, process_id, dictionary \\ nil) do
    GenServer.call(pid, {:spawn, process_id, dictionary})
  end

  def load(pid, process_id, source) do
    GenServer.call(pid, {:load, process_id, source})
  end

  # ---------------------------------------------
  # API Handler
  # ---------------------------------------------

  @impl true
  def handle_call({:execute, process_id, source, dictionary}, _from, core) do
    {core, process} = ForthVM.Core.spawn_process(core, process_id, dictionary)
    core = ForthVM.Core.execute(core, process.id, source)

    {:reply, core, core}
  end

  @impl true
  def handle_call({:spawn, process_id, dictionary}, _from, core) do
    {core, process} = ForthVM.Core.spawn_process(core, process_id, dictionary)

    {:reply, process, core}
  end

  @impl true
  def handle_call({:load, process_id, source}, _from, core) do
    core = ForthVM.Core.load(core, process_id, source)

    {:reply, core, core}
  end

  @impl true
  def handle_info(:tick, core) do
    core = ForthVM.Core.run(core)

    tick()

    {:noreply, core}
  end

  # ---------------------------------------------
  # Utilities
  # ---------------------------------------------

  defp tick() do
    Process.send_after(self(), :tick, @tick_interval)
  end
end