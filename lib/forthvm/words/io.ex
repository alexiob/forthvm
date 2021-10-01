defmodule ForthVM.Words.IO do
  alias ForthVM.Process

  # I/O operations

  def puts(process=%Process{}) do
    {process, value} = Process.pop(process)
    IO.puts(value)
    process
  end

  def inspect(process=%Process{}) do
    {process, value} = Process.pop(process)

    IO.inspect(value, label: "I >")

    process
  end
end
