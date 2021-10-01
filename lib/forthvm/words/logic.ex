defmodule ForthVM.Words.Logic do
  alias ForthVM.Process
  alias ForthVM.Token
  alias ForthVM.Words.Utils

  #=============================
  # logical operations
  #=============================

  def l_and(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    process
    |> Process.push(a and b)
  end

  def l_or(process=%Process{}) do
    {process, a, b} = Utils.pop2(process)

    Process.debug_puts(process, ">>> or: result=#{a or b} a=#{inspect(a)} b=#{inspect(b)}")

    process
    |> Process.push(a or b)
  end

  def l_not(process=%Process{}) do
    {process, a} = Process.pop(process)

    process
    |> Process.push(not Token.value(a))
  end
end
