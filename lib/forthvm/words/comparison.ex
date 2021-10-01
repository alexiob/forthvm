defmodule ForthVM.Words.Comparison do
  alias ForthVM.Process
  alias ForthVM.Words.Utils

  #=============================
  # comparison operations
  #=============================

  def le(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a <= b)
  end

  def lt(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a < b)
  end

  def ge(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a >= b)
  end

  def gt(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a > b)
  end

  def eq(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a == b)
  end

  def ne(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a != b)
  end
end
