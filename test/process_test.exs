defmodule ForthVM.ProcessTest do
  use ExUnit.Case, async: true
  import TestHelpers
  import ExUnit.CaptureIO

  alias ForthVM.Process

  @source_1 """
  3 39 +
  """

  @source_2 """
  (
    this
    is
    a
    multiline
    comment
  )
  include "./test/fixtures/hello-world.forth"

  hello-world
  """

  test "Process processor should exit normally" do
    {status, _context, exit_value} = core_run(@source_1)
    assert status == :exit
    assert exit_value == 42
  end

  test "Process processor should exit with yield" do
    {status, context, exit_value} = core_run(@source_1, 1)
    assert status == :yield
    assert exit_value == nil
    {status, _context, exit_value} = Process.run(context, 100)
    assert status == :exit
    assert exit_value == 42
  end

  test "Process processor should print hello world" do
    assert capture_io(fn -> core_run(@source_2) end) == "*** Hello wonderful world! ***\n"
  end
end
