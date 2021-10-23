defmodule Mix.Tasks.Repl do
  @moduledoc false
  use Mix.Task

  def run(_) do
    IO.puts("ForthVM REPL")

    ForthVM.Repl.Process.run()
  end
end
