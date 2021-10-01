defmodule ForthVM.Words.Stack do
  alias ForthVM.Process
  alias ForthVM.Stack

  #=============================
  # stack manipulation
  #=============================

  def dup(process=%Process{stack: stack}) do
    value = Stack.get(stack, 0)

    Process.debug_puts(process, ">>> dup: value=#{inspect(value)}")

    process = Process.push(process, value)

    Process.debug_inspect(process, process.stack, ">>> dup.stack")
  end

  def drop(process=%Process{}) do
    {process, _} = Process.pop(process)

    process
  end

  def swap(process=%Process{}) do
    {process, b} = Process.pop(process)
    {process, a} = Process.pop(process)

    process
    |> Process.push(b)
    |> Process.push(a)
  end

  def over(process=%Process{stack: stack}) do
    value = Stack.get(stack, 1)

    Process.push(process, value)
  end

  def rot(process=%Process{}) do
    {process, c} = Process.pop(process)
    {process, b} = Process.pop(process)
    {process, a} = Process.pop(process)

    process
    |> Process.push(b)
    |> Process.push(c)
    |> Process.push(a)
  end

  def depth(process=%Process{stack: stack}) do
    value = Stack.depth(stack)

    Process.push(process, value)
  end

  def pick(process=%Process{stack: stack}) do
    {process, idx} = Process.pop(process)

    value = Stack.get(stack, idx)

    Process.push(process, value)
  end
end
