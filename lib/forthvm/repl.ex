defmodule ForthVM.Repl do
  alias ForthVM.Core
  alias ForthVM.Core.Dictionary
  alias ForthVM.Tokenizer

  @prompt ">> "
  @reductions 100

  def context() do
    {[], [], [], Dictionary.new(), Core.new_meta()}
  end

  def run() do
    loop(context())
  end

  def loop(context) do
    input = IO.gets(@prompt)
    tokens = Tokenizer.parse(input)

    loop(process(tokens, context))
  end

  def process(command_tokens, {tokens, data_stack, return_stack, dictionary, meta})
      when is_list(tokens) do
    process({command_tokens ++ tokens, data_stack, return_stack, dictionary, meta})
  end

  def process(context) do
    case Core.run(context, @reductions) do
      {:exit, context, value} ->
        if value != nil do
          IO.inspect(value)
        end

        loop(context)

      {:yield, context, _} ->
        process(context)
    end
  end
end
