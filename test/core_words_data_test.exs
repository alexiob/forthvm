defmodule ForthVM.ProcessWordsDataTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import TestHelpers

  test "array definition" do
    assert {:exit, _, ["top", [44, 43, 42], "bottom"]} =
             process_run(~s/"bottom" l[ 44 43 42 ] "top"/)
  end

  test "array within an array definition" do
    assert {:exit, _, ["top", ["a", ["b", "c"], "d"], "bottom"]} =
             process_run(~s/"bottom" l[ a l[ b c ] d ] "top"/)
  end
end
