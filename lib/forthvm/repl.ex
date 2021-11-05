defmodule ForthVM.Repl do
  @moduledoc """
  Multiprocess REPL
  """
  @prompt ">> "
  @repl_num_cores 4
  @repl_core "core_1"
  @repl_process "repl"

  def run() do
    {:ok, _app_pid} = ForthVM.start(num_cores: @repl_num_cores)

    ForthVM.spawn(@repl_core, @repl_process)

    loop()
  end

  def loop() do
    input = IO.gets(@prompt)

    ForthVM.execute(@repl_core, @repl_process, input)

    loop()
  end
end
