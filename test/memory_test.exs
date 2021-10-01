defmodule ForthVM.MemoryTest do
  use ExUnit.Case

  alias ForthVM.Memory

  test "memory operations should work" do
    memory = Memory.new(3)

    {memory, pos, label} = Memory.add(memory, "string-1")
    assert Memory.size(memory) == 1
    assert pos == 0
    assert label == :nil

    {memory, pos, label} = Memory.add(memory, "string-2", :string_2)
    assert Memory.size(memory) == 2
    assert pos == 1
    assert label == :string_2

    {memory, pos, label} = Memory.add(memory, 42, :number_42)
    assert Memory.size(memory) == 3
    assert pos == 2
    assert label == :number_42

    assert Memory.get_label(memory, :string_2) == 1

    assert Memory.get(memory, Memory.get_label(memory, :string_2)) == Memory.get(memory, :string_2)
    assert Memory.get(Memory.set(memory, :string_2, "modifed string-2"), :string_2) == "modifed string-2"

    assert Memory.add(memory, "string-2", :string_2) == {:error, :out_of_memory, "out of memory (3)"}
  end
end
