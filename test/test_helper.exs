ExUnit.start()

defmodule TestHelpers do
  alias ForthVM.Tokenizer
  alias ForthVM.Core.Dictionary
  alias ForthVM.Core

  @reductions 1000

  def core_run(source, reductions \\ @reductions)

  def core_run(source, reductions) when is_binary(source) do
    core_run(Tokenizer.parse(source), reductions)
  end

  def core_run(tokens, reductions) when is_list(tokens) do
    Core.run(tokens, Dictionary.new(), reductions)
  end
end
