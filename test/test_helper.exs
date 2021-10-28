ExUnit.start()

defmodule TestHelpers do
  @moduledoc false

  alias ForthVM.Tokenizer
  alias ForthVM.Dictionary
  alias ForthVM.Process
  alias ForthVM.Core

  @reductions 1_000

  def process_run(source, reductions \\ @reductions)

  def process_run(source, reductions) when is_binary(source) do
    process_run(Tokenizer.parse(source), reductions)
  end

  def process_run(tokens, reductions) when is_list(tokens) do
    Process.run(tokens, Dictionary.new(), reductions)
  end

  def core_run(core, condition, reductions \\ @reductions)

  def core_run(%Core{} = core, condition, reductions) do
    core = Core.run(core, reductions)

    case condition.(core) do
      :continue -> core_run(core, condition, reductions)
      :stop -> core
    end
  end
end
