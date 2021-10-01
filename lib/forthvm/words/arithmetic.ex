defmodule ForthVM.Words.Arithmetic do
  alias ForthVM.Process
  alias ForthVM.Words.Utils

  #=============================
  # arithmetic operations
  #=============================

  def add(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a + b)
  end

  def sub(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a - b)
  end

  def mult(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a * b)
  end

  def div(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a / b)
  end

  def div_mod(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(div(a, b))
    |> Process.push(rem(a, b))
  end
end
