defmodule ForthVM.Stack do
  defstruct elements: []

  alias ForthVM.Stack

  def new, do: %Stack{}

  def push(stack, element) do
    %Stack{ stack | elements: [element | stack.elements]}
  end

  def pop(%Stack{elements: []}) do
    raise("stack is empty")
  end

  def pop(%Stack{elements: [ top | rest]}) do
    {top, %Stack{elements: rest}}
  end

  def depth(%Stack{elements: elements}) do
    length(elements)
  end

  def get(%Stack{elements: elements}, idx) when idx == 0 do
    hd(elements)
  end

  def get(%Stack{elements: elements}, idx) do
    Enum.at(elements, idx)
  end

  def set(%Stack{elements: elements} = stack, idx, value) do
    %{stack | elements: List.replace_at(elements, idx, value)}
  end
end
