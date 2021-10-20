defmodule ForthVM.ProcessWordStringTest do
  use ExUnit.Case, async: true
  import TestHelpers

  test "quoted string should return a string" do
    assert {:exit, _, "42 42 ="} = process_run(~s["42 42 ="])
  end
end
