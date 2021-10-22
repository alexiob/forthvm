defmodule Mix.Tasks.Repl do
  use Mix.Task

  def run(_) do
    IO.puts("ForthVM REPL")

    ForthVM.Repl.Process.run()
  end
end
