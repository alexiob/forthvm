defmodule ForthVM.Repl do
  @moduledoc """
  Multiprocess REPL
  """
  @prompt ">> "
  @repl_num_cores 4
  @repl_core "core_1"
  @repl_process "repl"

  def run() do
    {:ok, app_pid} = ForthVM.Application.start(nil, num_cores: @repl_num_cores)

    ForthVM.Application.spawn(@repl_core, @repl_process)

    loop()
  end

  def loop() do
    input = IO.gets(@prompt)

    ForthVM.Application.execute(@repl_core, @repl_process, input)

    loop()
  end
end
