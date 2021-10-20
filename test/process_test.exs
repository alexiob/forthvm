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

  test "Process should exit normally" do
    {status, _context, exit_value} = process_run(@source_1)
    assert status == :exit
    assert exit_value == 42
  end

  test "Process should exit with yield" do
    {status, context, exit_value} = process_run(@source_1, 1)
    assert status == :yield
    assert exit_value == nil
    {status, _context, exit_value} = Process.run(context, 100)
    assert status == :exit
    assert exit_value == 42
  end

  test "Process should print hello world" do
    assert capture_io(fn -> process_run(@source_2) end) == "*** Hello wonderful world! ***\n"
  end

  test "Process should load code and print hello world" do
    assert capture_io(fn ->
             process = ForthVM.Process.new("load and run", 1)

             ForthVM.Process.load(process.context, ForthVM.Tokenizer.parse(@source_2))
             |> ForthVM.Process.run(1000)
           end) == "*** Hello wonderful world! ***\n"
  end
end
