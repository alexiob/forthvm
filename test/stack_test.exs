defmodule ForthVM.StackTest do
  use ExUnit.Case

  alias ForthVM.Stack

  test "stack can push/pop elements" do
    stack = Stack.new()
    stack = Stack.push(stack, "first")
    stack = Stack.push(stack, "second")

    assert Stack.depth(stack) == 2

    {result, stack} = Stack.pop(stack)
    assert {result, stack} == {"second", %Stack{elements: ["first"]}}

    {result, stack} = Stack.pop(stack)
    assert {result, stack} == {"first", %Stack{elements: []}}

    assert_raise RuntimeError, "stack is empty", fn -> Stack.pop(stack) end

    assert Stack.depth(stack) == 0
  end
end
