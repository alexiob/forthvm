defmodule Mix.Tasks.Repl do
  @moduledoc """
  ForthVM REPL
  """
  use Mix.Task

  def run(_) do
    IO.puts("ForthVM REPL")

    ForthVM.Repl.run()
  end
end
