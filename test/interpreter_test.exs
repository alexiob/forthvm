defmodule ForthVM.InterpreterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias ForthVM.Process
  alias ForthVM.Interpreter

  test "interpreter should work" do
    source = """
    # "start" debug-process-trace
    # debug-disable

    (
      this
      is
      a
      multiline
      comment
    )
    include "./test/fixtures/hello-world"

    ( this is a another comment )
    # 'hello-world' debug-word-dump

    # "1" debug-process-trace
    # debug-enable

    # ::repeat
    #   hello-world
    #   branch :repeat

    # debug-disable

    # "2" debug-process-trace
    hello-world

    # "3" debug-process-trace
    # hello-world

    "final" debug-process-trace
    """

  end
end
