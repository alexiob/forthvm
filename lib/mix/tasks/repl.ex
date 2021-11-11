defmodule Mix.Tasks.Repl do
  @moduledoc """
  ForthVM REPL
  """
  use Mix.Task

  def run(_) do
    {:ok, version} = :application.get_key(:forthvm, :vsn)
    IO.puts("ForthVM REPL (v#{version})")

    ForthVM.Repl.run()
  end
end
