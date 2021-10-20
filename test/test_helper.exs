ExUnit.start()

defmodule TestHelpers do
  alias ForthVM.Tokenizer
  alias ForthVM.Dictionary
  alias ForthVM.Process

  @reductions 1000

  def process_run(source, reductions \\ @reductions)

  def process_run(source, reductions) when is_binary(source) do
    process_run(Tokenizer.parse(source), reductions)
  end

  def process_run(tokens, reductions) when is_list(tokens) do
    Process.run(tokens, Dictionary.new(), reductions)
  end
end
