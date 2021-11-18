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
      {Registry,
       keys: :duplicate, name: ForthVM.Subscriptions, partitions: System.schedulers_online()},
      ForthVM.IOCapture,
      ForthVM.IOLogger,
      {ForthVM.Core.Supervisor, num_cores: num_cores}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def core_pid(core_id) do
    [{core_pid, _core_module}] = Registry.lookup(ForthVM.Registry, ForthVM.Core.core_id(core_id))

    core_pid
  end

  def cores() do
    Supervisor.which_children(Process.whereis(ForthVM.Core.Supervisor))
    |> Enum.map(fn {core_id, core_pid, _, _} -> {Atom.to_string(core_id), core_pid} end)
    |> Enum.into(%{})
  end

  def execute(core_id, process_id, source, dictionary \\ nil) do
    ForthVM.Core.Worker.execute(core_pid(core_id), process_id, source, dictionary)
  end

  def load(core_id, process_id, source) do
    ForthVM.Core.Worker.load(core_pid(core_id), process_id, source)
  end

  def spawn(core_id, process_id, dictionary \\ nil) do
    ForthVM.Core.Worker.spawn(core_pid(core_id), process_id, dictionary)
  end

  def send_message(core_id, process_id, word_name, message_data) do
    ForthVM.Core.Worker.send_message(core_pid(core_id), process_id, word_name, message_data)
  end
end
