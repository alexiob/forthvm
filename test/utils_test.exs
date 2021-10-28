defmodule ForthVM.UtilsTest do
  @moduledoc false
  use ExUnit.Case
  require ForthVM.Utils
  alias ForthVM.Utils

  test "is_falsely should work" do
    assert Utils.is_falsely(false) == true
    assert Utils.is_falsely(nil) == true
    assert Utils.is_falsely(0) == true
    assert Utils.is_falsely("") == true

    assert Utils.is_falsely(true) == false
    assert Utils.is_falsely(:ok) == false
    assert Utils.is_falsely(1) == false
    assert Utils.is_falsely("123") == false
  end

  test "is_truthly should work" do
    assert Utils.is_truthly(true) == true
    assert Utils.is_truthly(:ok) == true
    assert Utils.is_truthly(1) == true
    assert Utils.is_truthly("123") == true

    assert Utils.is_truthly(false) == false
    assert Utils.is_truthly(nil) == false
    assert Utils.is_truthly(0) == false
    assert Utils.is_truthly("") == false
  end
end
