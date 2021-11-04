defmodule ForthVM.Application do
  @moduledoc """
  Starts a full Forth VirtualMachine, supporting multiple-core (Elixir processes) and processes (ForthVM ones)
  """

  use Application

  @impl true
  def start(_type, num_cores: num_cores) do
    children = [
      {ForthVM.Supervisor, num_cores: num_cores}
    ]

    opts = [strategy: :one_for_one, name: ForthVM]

    Supervisor.start_link(children, opts)
  end

  defdelegate core_pid(core_id), to: ForthVM.Supervisor
  defdelegate execute(core_id, process_id, source, dictionary \\ nil), to: ForthVM.Supervisor
  defdelegate load(core_id, process_id, source), to: ForthVM.Supervisor
  defdelegate spawn(core_id, process_id, dictionary \\ nil), to: ForthVM.Supervisor
end
