defmodule ForthVM.Words.Utils do
  alias ForthVM.Process
  alias ForthVM.Token

  def pop2(process=%Process{}) do
    {process, b} = Process.pop(process)
    {process, a} = Process.pop(process)

    {process, Token.value(a), Token.value(b)}
  end
end
