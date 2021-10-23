defmodule ForthVM.Words.Logic do
  @moduledoc """
  Comparison, logic and bitwise words
  """

  import ForthVM.Utils

  alias ForthVM.Process

  @c_true true
  @c_false false

  # ---------------------------------------------
  # Comparison operations
  # ---------------------------------------------

  @doc """
  =: ( x y -- bool ) check two values are equal. Works on different types
  """
  def eq(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x == y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  0=: ( x -- bool ) check value is euqal to 0
  """
  def zeq(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x == 0 | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  <>: ( x y -- bool ) check two values are different. Works on different types
  """
  def neq(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x != y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  <: ( x y -- bool ) check if x is less than y
  """
  def lt(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x < y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  <=: ( x y -- bool ) check if x is less than or equal to y
  """
  def lte(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x <= y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  >: ( x y -- bool ) check if x is greater than y
  """
  def gt(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x > y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  >=: ( x y -- bool ) check if x is greater than or equal to y
  """
  def gte(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x >= y | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  0<: ( x -- bool ) check if value is less than zero
  """
  def zle(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x < 0 | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  0>: ( x -- bool ) check if value is greater than zero
  """
  def zge(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [x > 0 | data_stack], return_stack, dictionary, meta)
  end

  # ---------------------------------------------
  # Logic operations
  # ---------------------------------------------

  @doc """
  true: ( -- bool ) the true constant
  """
  def const_true(tokens, data_stack, return_stack, dictionary, meta) do
    Process.next(tokens, [@c_true | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  false: ( -- bool ) the false constant
  """
  def const_false(tokens, data_stack, return_stack, dictionary, meta) do
    Process.next(tokens, [@c_false | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  and: ( x y -- bool ) logical and
  """
  def l_and(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    b =
      if is_truthly(x) and is_truthly(y) do
        @c_true
      else
        @c_false
      end

    Process.next(tokens, [b | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  or: ( x y -- bool ) logical or
  """
  def l_or(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    b =
      if is_truthly(x) or is_truthly(y) do
        @c_true
      else
        @c_false
      end

    Process.next(tokens, [b | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  not: ( x -- bool ) logical not
  """
  def l_not(tokens, [x | data_stack], return_stack, dictionary, meta) do
    b =
      if is_truthly(x) do
        @c_false
      else
        @c_true
      end

    Process.next(tokens, [b | data_stack], return_stack, dictionary, meta)
  end

  # ---------------------------------------------
  # Bits operations
  # ---------------------------------------------

  @doc """
  &: ( x y -- v ) bitwise and
  """
  def b_and(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [Bitwise.band(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  |: ( x y -- v ) bitwise or
  """
  def b_or(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [Bitwise.bor(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  ^: ( x y -- v ) bitwise xor
  """
  def b_xor(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [Bitwise.bxor(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  ~: ( x -- v ) bitwise not
  """
  def b_not(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [Bitwise.bnot(x) | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  <<: ( x y -- v ) bitwise shift left
  """
  def b_shift_left(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [Bitwise.bsl(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  >>: ( x y -- v ) bitwise shift right
  """
  def b_shift_right(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, [Bitwise.bsr(x, y) | data_stack], return_stack, dictionary, meta)
  end
end
