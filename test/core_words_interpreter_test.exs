defmodule ForthVM.CoreWordsInterpreterTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  import TestHelpers

  test "define square word" do
    assert {:exit, _, 16} = core_run(": square dup * ; 4 square")
  end

  test "true word becomes :true" do
    assert {:exit, _, true} = core_run("true")
  end

  test "true ( comment )" do
    assert {:exit, _, nil} = core_run("( this is a comment )")
  end

  test "false word becomes :false" do
    assert {:exit, _, false} = core_run("false")
  end

  test "end from inside function" do
    assert {:exit, _, 42} = core_run(": trigger end ; 42 trigger dup dup")
  end

  test "abort from inside function" do
    assert {:exit, _, nil} = core_run(": trigger abort ; 42 trigger dup dup")
  end

  test "abort? from inside function, truthly" do
    assert capture_io(fn -> assert {:exit, _, nil} = core_run(~s[: trigger abort? "see yah!" ; true trigger 42 dup dup]) end) == "see yah!\n"
  end

  test "abort? from inside function, falsely" do
    assert {:exit, _, [42, 42, 42]} = core_run(~s[: trigger abort? "see yah!" ; false trigger 42 dup dup])
  end

  test "define variable, set value, increment value, get value" do
    assert {:exit, _, 42} = core_run("variable test 41 test ! 1 test +! test @")
  end

  test "include a file" do
    IO.inspect(File.cwd!)
    assert capture_io(fn -> assert {:exit, _, _} = core_run(~w[include test/fixtures/hello-world.forth hello-world]) end) == "*** Hello wonderful world! ***\n"
  end

end
