defmodule ForthVM.InterpreterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias ForthVM.Process
  alias ForthVM.Interpreter

  test "interpreter should work" do
    source = """
    # 100 5 7 +
    # 10 20 >=

    # debug-enable

    : hello-world
    # first comment
    "*** Hello wonderful world! ***" puts # this is an inline comment
    "step"
    # second comment
    ;

    # 'hello-world' debug-word-dump

    # "1" debug-process-trace
    # debug-enable
    hello-world
    # debug-disable

    # "2" debug-process-trace
    # hello-world

    # "3" debug-process-trace
    # hello-world


    # "final" debug-process-trace
    """

    process = Process.new() |> Process.set_debug(false) |> Process.load(source, :main)
    output = capture_io(fn -> Interpreter.interpret(process, 200) end)

    assert output == "*** Hello wonderful world! ***\n"
  end
end
