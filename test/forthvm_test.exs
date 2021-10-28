defmodule ForthVMTest do
  @moduledoc false
  use ExUnit.Case
  doctest ForthVM

  test "greets the world" do
    assert ForthVM.hello() == :world
  end
end
