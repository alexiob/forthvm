defmodule ForthVM.Application do
  @moduledoc """
  Starts a full Forth VirtualMachine, supporting multiple-core (Elixir processes) and processes (ForthVM ones)
  """

  use Application

  @impl true
  def start(_type, num_cores: num_cores) do
    children = [
      {Registry, keys: :unique, name: ForthVM.Registry},
      {ForthVM.IOCapture, io_subscribers: []},
      ForthVM.IOLogger,
      {ForthVM.Supervisor, num_cores: num_cores}
    ]

    # IO.inspect(children, label: ">>> ForthVM.Application.children")

    opts = [strategy: :one_for_one, name: ForthVM]

    Supervisor.start_link(children, opts)
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
