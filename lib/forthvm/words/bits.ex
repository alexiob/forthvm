defmodule ForthVM.Words.Bits do
  alias ForthVM.Process
  alias ForthVM.Token
  alias ForthVM.Words.Utils

  #=============================
  # bits operations
  #=============================

  def b_and(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(Bitwise.band(a, b))
  end

  def b_or(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(Bitwise.bor(a, b))
  end

  def b_xor(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(Bitwise.bxor(a, b))
  end

  def b_not(process=%Process{}) do
    {process, a} = Process.pop(process)

    process
    |> Process.push(Bitwise.bnot(Token.value(a)))
  end

  def b_shift_left(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(Bitwise.bsl(a, b))
  end

  def b_shift_right(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(Bitwise.bsr(a, b))
  end
end
