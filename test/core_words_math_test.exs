defmodule ForthVM.ProcessWordsMathTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  import TestHelpers

  test "+" do
    assert {:exit, _, 42} = process_run("20 22 +")
  end

  test "+ float" do
    assert {:exit, _, 42.5} = process_run("20.5 22 +")
  end

  test "+ with string should error" do
    assert capture_io(fn ->
             assert {:error, _, "bad argument in arithmetic expression"} =
                      process_run("20 wrong +")
           end) == "Error: bad argument in arithmetic expression\n"
  end

  test "-" do
    assert {:exit, _, -2} = process_run("20 22 -")
  end

  test "- float" do
    assert {:exit, _, -2.5} = process_run("20 22.5 -")
  end

  test "*" do
    assert {:exit, _, 20} = process_run("4 5 *")
  end

  test "* float" do
    assert {:exit, _, 22.8} = process_run("4 5.7 *")
  end

  test "/" do
    assert {:exit, _, 4.0} = process_run("20 5 /")
  end

  test "/mod" do
    assert {:exit, _, [4, 1]} = process_run("21 5 /mod")
  end

  test "**" do
    assert {:exit, _, 16.0} = process_run("4 2 **")
  end

  test "1+" do
    assert {:exit, _, 42} = process_run("41 1+")
  end

  test "1-" do
    assert {:exit, _, 41} = process_run("42 1-")
  end

  test "abs 42" do
    assert {:exit, _, 42} = process_run("42 abs")
  end

  test "abs -42" do
    assert {:exit, _, 42} = process_run("-42 abs")
  end

  test "negate -42" do
    assert {:exit, _, 42} = process_run("-42 @-")
  end

  test "rand" do
    assert {:exit, _, number} = process_run("rand")
    assert is_number(number)
  end

  test "min" do
    assert {:exit, _, 42} = process_run("42 105 min")
  end

  test "max" do
    assert {:exit, _, 105} = process_run("42 105 max")
  end

  test "sqrt" do
    assert {:exit, _, 4.0} = process_run("16 sqrt")
  end

  test "sin" do
    _expected = :math.sin(42)
    assert {:exit, _, _expected} = process_run("42 sin")
  end

  test "cos" do
    _expeted = :math.cos(42)
    assert {:exit, _, _expected} = process_run("42 cos")
  end

  test "tan" do
    _expeted = :math.tan(42)
    assert {:exit, _, _expected} = process_run("42 tan")
  end

  test "pi" do
    _expeted = :math.pi()
    assert {:exit, _, _expected} = process_run("pi")
  end
end
