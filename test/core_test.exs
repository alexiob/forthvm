defmodule ForthVM.CoreTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import TestHelpers
  # import ExUnit.CaptureIO

  alias ForthVM.Core

  @source_loop """
  10 0 do
    "test" drop
  loop
  42
  """

  @source_sleep_loop """
  10 0 do
    10 sleep
  loop
  42
  """

  test "Core can find a process by id" do
    core = Core.new()
    {core, process} = Core.spawn_process(core)
    found_process = Core.find_process(core, process.id)

    assert process.id == found_process.id
  end

  test "Core executing source_loop should exit with 42" do
    core = Core.new()
    {core, process} = Core.spawn_process(core)

    core =
      core
      |> Core.load(process.id, @source_loop)
      |> Core.run()

    process = Core.find_process(core, process.id)

    assert process.status == :exit
    assert process.exit_value == 42
  end

  test "Core executing many source_loop should have all exit with 42" do
    core = Core.new()

    {core, process_1} = Core.spawn_process(core)
    {core, process_2} = Core.spawn_process(core)
    {core, process_3} = Core.spawn_process(core)
    {core, process_4} = Core.spawn_process(core)

    core =
      core
      |> Core.load(process_1.id, @source_loop)
      |> Core.load(process_2.id, @source_loop)
      |> Core.load(process_3.id, @source_loop)
      |> Core.load(process_4.id, @source_loop)
      |> Core.run()

    process_1 = Core.find_process(core, process_1.id)
    assert process_1.status == :exit
    assert process_1.exit_value == 42

    process_4 = Core.find_process(core, process_4.id)
    assert process_4.status == :exit
    assert process_4.exit_value == 42
  end

  test "Core executing source_sleep_loop should exit with 42 after sleeping" do
    core = Core.new()
    {core, process} = Core.spawn_process(core)

    core =
      core
      |> Core.load(process.id, @source_sleep_loop)
      |> core_run(fn core ->
        process = Core.find_process(core, process.id)

        case process.status do
          :exit -> :stop
          :yield -> :continue
        end
      end)

    process = Core.find_process(core, process.id)

    assert process.status == :exit
    assert process.exit_value == 42
  end

  test "Core executing two processes with source_sleep_loop should exit with 42 after sleeping" do
    core = Core.new()
    {core, process_1} = Core.spawn_process(core)
    {core, process_2} = Core.spawn_process(core)

    core =
      core
      |> Core.load(process_1.id, @source_sleep_loop)
      |> Core.load(process_2.id, @source_sleep_loop)
      |> core_run(fn core ->
        process = Core.find_process(core, process_2.id)

        case process.status do
          :exit -> :stop
          :yield -> :continue
        end
      end)

    process = Core.find_process(core, process_1.id)
    assert process.status == :exit
    assert process.exit_value == 42

    process = Core.find_process(core, process_2.id)
    assert process.status == :exit
    assert process.exit_value == 42
  end
end
