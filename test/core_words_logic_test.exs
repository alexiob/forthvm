defmodule ForthVM.CoreWordLogicTest do
  use ExUnit.Case, async: true
  import TestHelpers

  test "= numbers" do
    assert {:exit, _, true} = core_run("42 42 =")
  end

  test "= different numbers should be false" do
    assert {:exit, _, false} = core_run("42 41 =")
  end

  test "= strings" do
    assert {:exit, _, true} = core_run(~s["forty 2" "forty 2" =])
  end

  test "= different strings should be false" do
    assert {:exit, _, false} = core_run(~s["forty 2" "forty 1" =])
  end

  test "= number as a string and number" do
    assert {:exit, _, true} = core_run(~s["42" 42 =])
  end

  test "= number and string should be false" do
    assert {:exit, _, false} = core_run(~s["some" 42 =])
  end

  test "<> numbers" do
    assert {:exit, _, true} = core_run("42 41 <>")
  end

  test "<> same numbers should be false" do
    assert {:exit, _, false} = core_run("42 42 <>")
  end

  test "<> strings" do
    assert {:exit, _, true} = core_run(~s["a" "b" <>])
  end

  test "<> same strings should be false" do
    assert {:exit, _, false} = core_run(~s["a" "a" <>])
  end

  test "< numbers" do
    assert {:exit, _, true} = core_run("41 42 <")
  end

  test "< numbers with greater should be false" do
    assert {:exit, _, false} = core_run("42 41 <")
  end

  test "< equal numbers should be false" do
    assert {:exit, _, false} = core_run("42 42 <")
  end

  test "< a and b strings should be true" do
    assert {:exit, _, true} = core_run(~s["a" "b" <])
  end

  test "< b and a strings should be false" do
    assert {:exit, _, false} = core_run(~s["b" "a" <])
  end

  test "< a and a strings should be false" do
    assert {:exit, _, false} = core_run(~s["a" "a" <])
  end

  test "<= numbers" do
    assert {:exit, _, true} = core_run("41 42 <=")
  end

  test "<= numbers with greater should be false" do
    assert {:exit, _, false} = core_run("42 41 <=")
  end

  test "<= equal numbers should be true" do
    assert {:exit, _, true} = core_run("42 42 <=")
  end

  test "<= a and b strings should be true" do
    assert {:exit, _, true} = core_run(~s["a" "b" <=])
  end

  test "<= b and a strings should be false" do
    assert {:exit, _, false} = core_run(~s["b" "a" <=])
  end

  test "<= a and a strings should be true" do
    assert {:exit, _, true} = core_run(~s["a" "a" <=])
  end

  test "> numbers" do
    assert {:exit, _, true} = core_run("42 41 >")
  end

  test "> numbers with greater should be false" do
    assert {:exit, _, false} = core_run("41 42 >")
  end

  test "> equal numbers should be false" do
    assert {:exit, _, false} = core_run("42 42 >")
  end

  test "> a and b strings should be false" do
    assert {:exit, _, false} = core_run(~s["a" "b" >])
  end

  test "> b and a strings should be true" do
    assert {:exit, _, true} = core_run(~s["b" "a" >])
  end

  test "> a and a strings should be false" do
    assert {:exit, _, false} = core_run(~s["a" "a" >])
  end

  test ">= numbers" do
    assert {:exit, _, true} = core_run("42 41 >=")
  end

  test ">= numbers with lesser should be false" do
    assert {:exit, _, false} = core_run("41 42 >=")
  end

  test ">= equal numbers should be true" do
    assert {:exit, _, true} = core_run("42 42 >=")
  end

  test ">= a and b strings should be false" do
    assert {:exit, _, false} = core_run(~s["a" "b" >=])
  end

  test ">= b and a strings should be true" do
    assert {:exit, _, true} = core_run(~s["b" "a" >=])
  end

  test ">= a and a strings should be true" do
    assert {:exit, _, true} = core_run(~s["a" "a" >=])
  end

  test "0< -1 number less than zero should be true" do
    assert {:exit, _, true} = core_run("-1 0<")
  end

  test "0< 1 number less than zero should be false" do
    assert {:exit, _, false} = core_run("1 0<")
  end

  test "0< 0 number less than zero should be false" do
    assert {:exit, _, false} = core_run("0 0<")
  end

  test "0> -1 number greater than zero should be false" do
    assert {:exit, _, false} = core_run("-1 0>")
  end

  test "0> 1 number greater than zero should be true" do
    assert {:exit, _, true} = core_run("1 0>")
  end

  test "0> 0 number greater than zero should be false" do
    assert {:exit, _, false} = core_run("0 0>")
  end

  test "constant 'true' should be true" do
    assert {:exit, _, true} = core_run(["true"])
  end

  test "constant 'false' should be false" do
    assert {:exit, _, false} = core_run(["false"])
  end

  test "'true' and true should be true" do
    assert {:exit, _, true} = core_run(["true", true, "and"])
  end

  test "'false' and false should be false" do
    assert {:exit, _, false} = core_run(["false", false, "and"])
  end

  test "'true' and false should be false" do
    assert {:exit, _, false} = core_run(["true", false, "and"])
  end

  test "'false' and true should be false" do
    assert {:exit, _, false} = core_run(["false", true, "and"])
  end

  test "1 and 2 should be true" do
    assert {:exit, _, true} = core_run([1, 2, "and"])
  end

  test "1 and 0 should be false" do
    assert {:exit, _, false} = core_run([1, 0, "and"])
  end

  test "'a' and 'b' should be true" do
    assert {:exit, _, true} = core_run(["a", "b", "and"])
  end

  test "'a' and '' should be false" do
    assert {:exit, _, false} = core_run(["a", "", "and"])
  end

  test "'a' and 1 should be true" do
    assert {:exit, _, true} = core_run(["a", 1, "and"])
  end

  test "'a' and 0 should be false" do
    assert {:exit, _, false} = core_run(["a", 0, "and"])
  end

  test "'true' or true should be true" do
    assert {:exit, _, true} = core_run(["true", true, "or"])
  end

  test "'false' or false should be false" do
    assert {:exit, _, false} = core_run(["false", false, "or"])
  end

  test "'true' or false should be true" do
    assert {:exit, _, true} = core_run(["true", false, "or"])
  end

  test "'false' or true should be true" do
    assert {:exit, _, true} = core_run(["false", true, "or"])
  end

  test "1 or 2 should be true" do
    assert {:exit, _, true} = core_run([1, 2, "or"])
  end

  test "1 or 0 should be true" do
    assert {:exit, _, true} = core_run([1, 0, "or"])
  end

  test "'a' or 'b' should be true" do
    assert {:exit, _, true} = core_run(["a", "b", "or"])
  end

  test "'' or 'a' should be true" do
    assert {:exit, _, true} = core_run(["", "a", "or"])
  end

  test "'a' or 1 should be true" do
    assert {:exit, _, true} = core_run(["a", 1, "or"])
  end

  test "0 or 'a' should be true" do
    assert {:exit, _, true} = core_run([0, "a", "or"])
  end

  test "not 0 should be true" do
    assert {:exit, _, true} = core_run([0, "not"])
  end

  test "not 1 should be false" do
    assert {:exit, _, false} = core_run([1, "not"])
  end

  test "not '' should be true" do
    assert {:exit, _, true} = core_run(["", "not"])
  end

  test "not 'a' should be false" do
    assert {:exit, _, false} = core_run(["a", "not"])
  end

  test "not false should be true" do
    assert {:exit, _, true} = core_run([false, "not"])
  end

  test "not 'false' should be true" do
    assert {:exit, _, true} = core_run(["false", "not"])
  end

  test "not true should be false" do
    assert {:exit, _, false} = core_run([true, "not"])
  end

  test "not 'true' should be false" do
    assert {:exit, _, false} = core_run(["true", "not"])
  end

  test "0 & 1 should be 0" do
    assert {:exit, _, 0} = core_run([0, 1, "&"])
  end

  test "1 & 1 should be 1" do
    assert {:exit, _, 1} = core_run([1, 1, "&"])
  end

  test "1 & 2 should be 0" do
    assert {:exit, _, 0} = core_run([1, 2, "&"])
  end

  test "1 & 3 should be 1" do
    assert {:exit, _, 1} = core_run([1, 3, "&"])
  end

  test "7 & 3 should be 3" do
    assert {:exit, _, 3} = core_run([7, 3, "&"])
  end

  test "42 & 48 should be 32" do
    assert {:exit, _, 32} = core_run([42, 48, "&"])
  end

  test "48 & 42 should be 32" do
    assert {:exit, _, 32} = core_run([48, 42, "&"])
  end

  test "'48' & 42 should error" do
    assert {:error, _, "bad argument in arithmetic expression"} = core_run(["48", 42, "&"])
  end

  test "0 | 1 should be 1" do
    assert {:exit, _, 1} = core_run([0, 1, "|"])
  end

  test "1 | 1 should be 1" do
    assert {:exit, _, 1} = core_run([1, 1, "|"])
  end

  test "1 | 2 should be 3" do
    assert {:exit, _, 3} = core_run([1, 2, "|"])
  end

  test "2 | 1 should be 3" do
    assert {:exit, _, 3} = core_run([2, 1, "|"])
  end

  test "0 ^ 1 should be 1" do
    assert {:exit, _, 1} = core_run([0, 1, "^"])
  end

  test "1 ^ 0 should be 1" do
    assert {:exit, _, 1} = core_run([1, 0, "^"])
  end

  test "1 ^ 1 should be 0" do
    assert {:exit, _, 0} = core_run([1, 1, "^"])
  end

  test "1 ^ 2 should be 3" do
    assert {:exit, _, 3} = core_run([1, 2, "^"])
  end

  test "3 ^ 1 should be 2" do
    assert {:exit, _, 2} = core_run([3, 1, "^"])
  end

  test "~ 0 should be -1" do
    assert {:exit, _, -1} = core_run([0, "~"])
  end

  test "~ 1 should be -2" do
    assert {:exit, _, -2} = core_run([1, "~"])
  end

  test "~ -1 should be 0" do
    assert {:exit, _, 0} = core_run([-1, "~"])
  end

  test "~ -2 should be 1" do
    assert {:exit, _, 1} = core_run([-2, "~"])
  end

  test "0 << 1 should be 0" do
    assert {:exit, _, 0} = core_run([0, 1, "<<"])
  end

  test "1 << 1 should be 2" do
    assert {:exit, _, 2} = core_run([1, 1, "<<"])
  end

  test "1 << 2 should be 4" do
    assert {:exit, _, 4} = core_run([1, 2, "<<"])
  end

  test "0 >> 1 should be 0" do
    assert {:exit, _, 0} = core_run([0, 1, ">>"])
  end

  test "1 >> 1 should be 0" do
    assert {:exit, _, 0} = core_run([1, 1, ">>"])
  end

  test "2 >> 1 should be 1" do
    assert {:exit, _, 1} = core_run([2, 1, ">>"])
  end
end
