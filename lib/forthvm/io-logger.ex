defmodule ForthVM.IOLogger do
  @moduledoc """
  Collects ad logs all outputs from all core/processes.
  """
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple("io_logger"))
  end

  def via_tuple(id) do
    {:via, Registry, {ForthVM.Registry, id, __MODULE__}}
  end

  @impl true
  def init(_state) do
    ForthVM.IOCapture.register()

    {:ok, %{}}
  end

  # ---------------------------------------------
  # API Handler
  # ---------------------------------------------

  @impl true
  def handle_info(
        {:command_stdout, string, _encoding},
        state
      ) do
    IO.puts(string)

    {:noreply, state}
  end
end
