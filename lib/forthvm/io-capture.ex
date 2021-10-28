defmodule ForthVM.IOCapture do
  @moduledoc """
  Collect all outputs from a set of cores/processes and dispatch them to registered listeners.
  """
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(ForthVM.IOCapture))
  end

  def via_tuple(id) do
    {:via, Registry, {ForthVM.Registry, id, ForthVM.IOCapture}}
  end

  @impl true
  def init(io_subscribers: io_subscribers) do
    {:ok, %{io_subscribers: io_subscribers}}
  end

  # ---------------------------------------------
  # API
  # ---------------------------------------------

  def pid() do
    [{io_capture_pid, _io_capture}] = Registry.lookup(ForthVM.Registry, ForthVM.IOCapture)
    io_capture_pid
  end

  def register(io_subscriber_pid) do
    GenServer.call(pid(), {:register, io_subscriber_pid})
  end

  def unregister(io_subscriber_pid) do
    GenServer.call(pid(), {:unregister, io_subscriber_pid})
  end

  # ---------------------------------------------
  # API Handler
  # ---------------------------------------------

  @impl true
  def handle_call({:register, process_id}, _from, %{io_subscribers: io_subscribers} = state) do
    state = %{state | io_subscribers: [process_id | io_subscribers]}
    {:reply, state, state}
  end

  @impl true
  def handle_call({:unregister, process_id}, _from, %{io_subscribers: io_subscribers} = state) do
    state = %{state | io_subscribers: Enum.reject(io_subscribers, &Kernel.==(&1, process_id))}
    {:reply, state, state}
  end

  # ---------------------------------------------
  # IO Handler
  # ---------------------------------------------

  @impl true
  def handle_info(
        {:io_request, pid, reply_as, {:put_chars, encoding, string}},
        %{io_subscribers: io_subscribers} = state
      ) do
    # IO.inspect(string, label: ">>> io_request.string")

    send(pid, {:io_reply, reply_as, :ok})
    notify_io_subscribers(io_subscribers, {:command_stdout, string, encoding})

    {:noreply, state}
  end

  def handle_info({:render, content}, %{io_subscribers: io_subscribers} = state) do
    IO.inspect(content, label: ">>> render")

    notify_io_subscribers(io_subscribers, {:command_output, %{outputs: content}})

    {:noreply, state}
  end

  def handle_info({:finish, pid}, state) do
    IO.inspect(pid, label: ">>> finish")
    send(pid, {:finished})

    {:noreply, state}
  end

  def handle_info(unknown, state) do
    IO.inspect(unknown, label: ">>> unknown")

    {:noreply, state}
  end

  # ---------------------------------------------
  # Utilities
  # ---------------------------------------------

  defp notify_io_subscribers(io_subscribers, data) do
    # IO.inspect(io_subscribers, label: "notify_io_subscribers")
    # IO.inspect(data, label: "notify_io_subscribers.data")

    io_subscribers
    |> Stream.each(fn pid -> send(pid, data) end)
    |> Stream.run()
  end
end
