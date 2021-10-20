defmodule ForthVM.ProcessWordsStackTest do
  use ExUnit.Case, async: true
  import TestHelpers

  test "depth" do
    assert {:exit, _, [2 | _]} = process_run("20 22 depth")
  end

  test "drop" do
    assert {:exit, _, 20} = process_run("20 22 drop")
  end

  test "2drop" do
    assert {:exit, _, 20} = process_run("20 22 24 2drop")
  end

  test "dup" do
    assert {:exit, _, [22, 22, 20]} = process_run("20 22 dup")
  end

  test "2dup" do
    assert {:exit, _, [22, 20, 22, 20]} = process_run("20 22 2dup")
  end

  test "?dup truthly" do
    assert {:exit, _, [22, 22, 20]} = process_run("20 22 ?dup")
  end

  test "?dup falsely" do
    assert {:exit, _, [0, 20]} = process_run("20 0 ?dup")
  end

  test "swap" do
    assert {:exit, _, [1, 2, "bottom"]} = process_run("bottom 1 2 swap")
  end

  test "2swap" do
    assert {:exit, _, [2, 1, 4, 3, "bottom"]} = process_run("bottom 1 2 3 4 2swap")
  end

  test "over" do
    assert {:exit, _, [1, 2, 1]} = process_run("1 2 over")
  end

  test "2over" do
    assert {:exit, _, [2, 1, 4, 3, 2, 1, "bottom"]} = process_run("bottom 1 2 3 4 2over")
  end

  test "rot" do
    assert {:exit, _, [2, 4, 3, 1, "bottom"]} = process_run("bottom 1 2 3 4 rot")
  end

  test "-rot" do
    assert {:exit, _, [3, 2, 4, 1, "bottom"]} = process_run("bottom 1 2 3 4 -rot")
  end
end
