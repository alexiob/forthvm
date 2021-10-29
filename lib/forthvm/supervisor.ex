defmodule ForthVM.Supervisor do
  @moduledoc """
  Ssupervisor providing Cores, IO capture, IO logger, and registry.
  """
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(num_cores: num_cores) do
    children = [
      {Registry, keys: :unique, name: ForthVM.Registry},
      {ForthVM.IOCapture, io_subscribers: []},
      ForthVM.IOLogger,
      {ForthVM.Core.Supervisor, num_cores: num_cores}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def core_pid(core_id) do
    [{core_pid, _core_module}] = Registry.lookup(ForthVM.Registry, ForthVM.Core.core_id(core_id))

    core_pid
  end

  def execute(core_id, process_id, source, dictionary \\ nil) do
    ForthVM.Worker.execute(core_pid(core_id), process_id, source, dictionary)
  end

  def load(core_id, process_id, source) do
    ForthVM.Worker.load(core_pid(core_id), process_id, source)
  end

  def spawn(core_id, process_id, dictionary \\ nil) do
    ForthVM.Worker.spawn(core_pid(core_id), process_id, dictionary)
  end
end
