defmodule ForthVM.Words.Math do
  alias ForthVM.Core

  #---------------------------------------------
  # Basic math operations
  #---------------------------------------------

  @doc"""
  +: ( y x -- n ) sums y to x
  """
  def plus(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [x + y | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  -: ( y x -- n ) subtracts y from x
  """
  def minus(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [x - y | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  *: ( x y -- n ) multiplies x by y
  """
  def mult(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [x * y | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  /: ( x y -- n ) divides x by y
  """
  def div(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [x / y | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  /mod: ( x y -- rem div ) divides x by y, places divident and reminder on top of data stack
  """
  def mod(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [div(x, y), rem(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  **: ( x y -- n ) calculates pow of x by y
  """
  def pow(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [:math.pow(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  1+: ( x -- n ) adds 1 to x
  """
  def one_plus(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [x + 1 | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  1-: ( x -- n ) subtracts 1 to x
  """
  def one_minus(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [x - 1 | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  @-, negate: ( x -- n ) negates x
  """
  def negate(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [-x | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  abs: ( x -- n ) absolute of x
  """
  def abs(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [abs(x) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  rand: ( -- n ) puts random number on stack
  """
  def rand(tokens, data_stack, return_stack, dictionary, meta) do
    Core.next(tokens, [:rand.uniform() | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  min: ( x y -- n ) minimum between two values
  """
  def min(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [min(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  max: ( x y -- n ) miaximum between two values
  """
  def max(tokens, [y, x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [max(x, y) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  sqrt: ( x -- n ) sqrt of x
  """
  def sqrt(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [:math.sqrt(x) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  sin: ( x -- n ) sin of x
  """
  def sin(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [:math.sin(x) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  cos: ( x -- n ) cos of x
  """
  def cos(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [:math.cos(x) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  tan: ( x -- n ) tan of x
  """
  def yan(tokens, [x | data_stack], return_stack, dictionary, meta) do
    Core.next(tokens, [:math.tan(x) | data_stack], return_stack, dictionary, meta)
  end

  @doc"""
  pi: ( -- n ) puts Pi value on top of stack
  """
  def pi(tokens, data_stack, return_stack, dictionary, meta) do
    Core.next(tokens, [:math.pi() | data_stack], return_stack, dictionary, meta)
  end

end
