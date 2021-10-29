defmodule ForthVM.Core.Supervisor do
  @moduledoc """
  Supervisor of multiple ForthVM.Cores (equivalent to Elixir processes).
  """
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(num_cores: num_cores) do
    children =
      Enum.map(1..num_cores, fn id ->
        core_id = String.to_atom(ForthVM.Core.core_id(id))
        Supervisor.child_spec({ForthVM.Core.Worker, id: id}, id: core_id)
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def cores(pid) do
    Supervisor.which_children(pid)
  end
end
