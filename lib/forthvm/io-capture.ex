defmodule ForthVM.IOCapture do
  @moduledoc """
  Collect all outputs from a set of cores/processes and dispatch them to registered listeners.
  """
  use GenServer

  def start_link(_init_args) do
    start_link()
  end

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: via_tuple(ForthVM.IOCapture))
  end

  def via_tuple(id) do
    {:via, Registry, {ForthVM.Registry, id, ForthVM.IOCapture}}
  end

  @impl true
  def init(_init_args) do
    {:ok, %{}}
  end

  # ---------------------------------------------
  # API
  # ---------------------------------------------

  def pid() do
    [{io_capture_pid, _io_capture}] = Registry.lookup(ForthVM.Registry, ForthVM.IOCapture)
    io_capture_pid
  end

  def register() do
    Registry.register(ForthVM.Subscriptions, :io_subscribers, [])
  end

  def unregister() do
    Registry.unregister(ForthVM.Subscriptions, :io_subscribers)
  end

  # ---------------------------------------------
  # IO Handler
  # ---------------------------------------------

  @impl true
  def handle_info(
        {:io_request, pid, reply_as, {:put_chars, encoding, string}},
        state
      ) do
    # IO.inspect(string, label: ">>> io_request.string")

    send(pid, {:io_reply, reply_as, :ok})
    notify_io_subscribers({:command_stdout, string, encoding})

    {:noreply, state}
  end

  def handle_info({:render, content}, state) do
    IO.inspect(content, label: ">>> render")

    notify_io_subscribers({:command_output, %{outputs: content}})

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

  def notify_io_subscribers(data) when not is_tuple(data) do
    notify_io_subscribers({:command_stdout, data, nil})
  end

  def notify_io_subscribers(data) do
    # IO.inspect(io_subscribers, label: "notify_io_subscribers")
    # IO.inspect(data, label: "notify_io_subscribers.data")

    Registry.dispatch(ForthVM.Subscriptions, :io_subscribers, fn entries ->
      for {pid, _} <- entries, do: send(pid, data)
    end)
  end
end
