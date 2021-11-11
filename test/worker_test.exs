defmodule ForthVM.Core.WorkerTest do
  @moduledoc false
  use ExUnit.Case, async: true

  test "Worker should print hello world" do
    {:ok, _registry_pid} = Registry.start_link(keys: :unique, name: ForthVM.Registry)

    {:ok, _io_capture_registry_pid} =
      Registry.start_link(
        keys: :duplicate,
        name: ForthVM.Subscriptions,
        partitions: System.schedulers_online()
      )

    {:ok, _io_capture__pid} = ForthVM.IOCapture.start_link([])

    {:ok, worker_pid} = ForthVM.Core.Worker.start_link(id: 1)

    ForthVM.IOCapture.register()

    ForthVM.Core.Worker.execute(worker_pid, 1, "\"hello world\" puts")
    assert_receive {:command_stdout, "hello world", _encoding}, 1_000

    ForthVM.Core.Worker.spawn(worker_pid, 2)
    ForthVM.Core.Worker.load(worker_pid, 2, "\"hello world\n\" puts")
    assert_receive {:command_stdout, "hello world\n", _encoding}, 1_000
  end
end
