defmodule ForthVM.VM.Supervisor do
  @moduledoc """
  FoththVM supporting multiple ForthVM.Cores (equivalent to Elixir processes).
  """
  use DynamicSupervisor

  alias ForthVM.Core.Worker

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_core(id) do
    spec = {Worker, id: id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
