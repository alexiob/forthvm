defmodule ForthVM.Words.Stack do
  alias ForthVM.Process

  import ForthVM.Utils

  # ---------------------------------------------
  # Stack operations
  # ---------------------------------------------

  @doc """
  depth: ( -- x ) get stack depth
  """
  def depth(tokens, data_stack, return_stack, dictionary, meta) do
    Process.next(tokens, [length(data_stack) | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  drop: ( x -- ) remove element from top of stack
  """
  def drop(tokens, [_ | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  2drop: ( x y -- ) remove two elements from top of stack
  """
  def drop2(tokens, [_, _ | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  dup: ( x -- x x ) duplicate element from top of stack
  """
  def dup(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x, x | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  2dup: ( x y -- x y x y ) duplicate two elements from top of stack
  """
  def dup2(tokens, [x, y | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x, y, x, y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  ?dup: ( x -- x x ) duplicate element from top of stack if element value is truthly
  """
  def dup?(tokens, [x | _] = data_stack, return_stack, dictionary, meta) when is_falsely(x) do
    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  def dup?(tokens, [x | _] = data_stack, return_stack, dictionary, meta) do
    Process.next(tokens, [x | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  swap: ( x y -- y x ) swap top two elements on top of stack
  """
  def swap(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x, y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  2swap: ( y2 x2 y1 x1 -- y1 x1 y2 x2 ) swap top copules on top of stack
  """
  def swap2(tokens, [x1, y1, x2, y2 | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x2, y2, x1, y1 | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  over: (y x -- y x y) copy second element on top of stack
  """
  def over(tokens, [x, y | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [y, x, y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  2over: ( y2 x2 y1 x1 -- y2 x2 y1 x1 y2 x2) swap top copules on top of stack
  """
  def over2(tokens, [x1, y1, x2, y2 | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x2, y2, x1, y1, x2, y2 | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  rot: ( x y z -- y z x ) rotate the top three stack entries, bottom goes on top
  """
  def rot(tokens, [z, y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x, z, y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  -rot: ( x y z -- z x y ) rotate the top three stack entries, top goes on bottom
  """
  def rot_neg(tokens, [z, y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [y, x, z | data_stack], return_stack, dictionary, meta)
  end
end
