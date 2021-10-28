defmodule ForthVM.WorkerTest do
  @moduledoc false
  use ExUnit.Case, async: true

  test "Worker should print hello world" do
    {:ok, _registry_pid} = Registry.start_link(keys: :unique, name: ForthVM.Registry)
    {:ok, _io_capture__pid} = ForthVM.IOCapture.start_link(io_subscribers: [])
    {:ok, worker_pid} = ForthVM.Worker.start_link(id: 1)

    ForthVM.IOCapture.register(self())

    ForthVM.Worker.execute(worker_pid, 1, "\"hello world\" puts")
    assert_receive {:command_stdout, "hello world\n", _encoding}, 1_000

    ForthVM.Worker.spawn(worker_pid, 2)
    ForthVM.Worker.load(worker_pid, 2, "\"hello world\" puts")
    assert_receive {:command_stdout, "hello world\n", _encoding}, 1_000
  end
end