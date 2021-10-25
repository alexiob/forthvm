defmodule ForthVM.Core.Worker do
  @moduledoc """
  Core supervised worker
  """
  use GenServer

  alias ForthVM.Core

  def start_link([id: id] = state) do
    id = id || System.unique_integer()
    io = Keyword.get(state, :io, :stdio)

    name = String.to_atom("core#{id}")

    GenServer.start_link(__MODULE__, [id: id, io: io], name: name)
  end

  @impl true
  def init(id: id, io: io) do
    {:ok, Core.new(id, io)}
  end
end
