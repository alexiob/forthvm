defmodule ForthVMTest do
  use ExUnit.Case
  doctest ForthVM

  test "greets the world" do
    assert ForthVM.hello() == :world
  end
end
