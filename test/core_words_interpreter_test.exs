defmodule ForthVM.ProcessWordsInterpreterTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  import TestHelpers

  test "define square word" do
    assert {:exit, _, 16} = process_run(": square dup * ; 4 square")
  end

  test "define sum-of-square word" do
    assert {:exit, _, 25} = process_run(~s[
      : square ( n -- nsqared ) dup * ;
      : sum-of-squares ( a b -- c ) square swap square + ;
      3 4 sum-of-squares
    ])
  end

  test "factorial" do
    assert {:exit, _, 720} = process_run(~s[
      ( Checks if we've decremented below 1; if not, recurse )
      : inner_factorial dup 1 > if dup rot * swap 1- inner_factorial else drop then ;
      ( Entry point. Pushes a running total onto the stack and swaps )
      : factorial 1 swap inner_factorial ;
      6 factorial
    ])
  end

  test "true word becomes :true" do
    assert {:exit, _, true} = process_run("true")
  end

  test "true ( comment )" do
    assert {:exit, _, nil} = process_run("( this is a comment )")
  end

  test "false word becomes :false" do
    assert {:exit, _, false} = process_run("false")
  end

  test "end from inside function" do
    assert {:exit, _, 42} = process_run(": trigger end ; 42 trigger dup dup")
  end

  test "abort from inside function" do
    assert {:exit, _, nil} = process_run(": trigger abort ; 42 trigger dup dup")
  end

  test "abort? from inside function, truthly" do
    assert capture_io(fn ->
             assert {:exit, _, nil} =
                      process_run(~s[: trigger abort? "see yah!" ; true trigger 42 dup dup])
           end) == "see yah!\n"
  end

  test "abort? from inside function, falsely" do
    assert {:exit, _, [42, 42, 42]} =
             process_run(~s[: trigger abort? "see yah!" ; false trigger 42 dup dup])
  end

  test "processing should resume after 1 second" do
    {status, context, exit_value} = process_run("100 sleep 42")
    assert status == :yield
    assert exit_value == nil
    :timer.sleep(50)
    {status, context, exit_value} = ForthVM.Process.run(context, 1_000)
    assert status == :yield
    assert exit_value == nil
    :timer.sleep(55)
    {status, _context, exit_value} = ForthVM.Process.run(context, 1_000)
    assert status == :exit
    assert exit_value == 42
  end

  test "define variable, set value, increment value, get value" do
    assert {:exit, _, 42} = process_run("variable test 41 test ! 1 test +! test @")
  end

  test "re-define variable should just return previously defined one" do
    assert {:exit, context, 42} = process_run("variable test 42 test ! test @")

    assert {:exit, _context, 42} =
             ForthVM.Process.execute(
               context,
               ForthVM.Tokenizer.parse("variable test"),
               1000
             )
  end

  test "set an undefined variable should error" do
    assert capture_io(fn ->
             assert {:error, _, "can not set unknown variable 'test' with value '42'"} =
                      process_run("42 test !")
           end) == "Error: can not set unknown variable 'test' with value '42'\n"
  end

  test "increment an undefined variable should error" do
    assert capture_io(fn ->
             assert {:error, _, "can not increment unknown variable 'test' by '42'"} =
                      process_run("42 test +!")
           end) == "Error: can not increment unknown variable 'test' by '42'\n"
  end

  test "fetch an undefined variable should error" do
    assert capture_io(fn ->
             assert {:error, _, "can not fetch unknown variable 'test'"} = process_run("test @")
           end) == "Error: can not fetch unknown variable 'test'\n"
  end

  test "define constant, get value" do
    assert {:exit, _, 42} = process_run("42 constant test test")
  end

  test "setting an already defined constant should error" do
    assert capture_io(fn ->
             assert {:error, _, "can not set already defined constant 'test' with new value '1'"} =
                      process_run("42 constant test 1 constant test")
           end) == "Error: can not set already defined constant 'test' with new value '1'\n"
  end

  test "include a file" do
    assert capture_io(fn ->
             assert {:exit, _, _} =
                      process_run(~w[include test/fixtures/hello-world.forth hello-world])
           end) == "*** Hello wonderful world! ***\n"
  end

  test "include an unknown file sould error" do
    assert capture_io(fn ->
             assert {:error, _, "can not include 'unknown.forth' because ':enoent'"} =
                      process_run(~w[include unknown.forth hello-world])
           end) == "Error: can not include 'unknown.forth' because ':enoent'\n"
  end
end
