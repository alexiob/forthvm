defmodule ForthVM.Repl.Process do
  @moduledoc """
  DEPRECATED - here just as a guideline on how to handle process state changes
  A single process REPL
  """
  alias ForthVM.Process
  alias ForthVM.Dictionary
  alias ForthVM.Tokenizer

  @prompt ">> "
  @reductions 100

  def context() do
    {[], [], [], Dictionary.new(), Process.new_meta(nil, nil)}
  end

  def run() do
    loop(context())
  end

  def loop({_, _, _, _, meta} = context) do
    io = meta.io.device
    input = IO.gets(io, @prompt)
    tokens = Tokenizer.parse(input)

    loop(process(tokens, context))
  end

  def process(command_tokens, {tokens, data_stack, return_stack, dictionary, meta})
      when is_list(tokens) do
    process({command_tokens ++ tokens, data_stack, return_stack, dictionary, meta})
  end

  def process({_, _, _, _, meta} = context) do
    io = meta.io.device

    case Process.run(context, @reductions) do
      {:exit, context, value} ->
        if value != nil do
          IO.inspect(io, value)
        end

        loop(context)

      {:error, context, message} ->
        IO.puts(io, "> Error #{message}")

        loop(context)

      {:yield, context, _} ->
        process(context)
    end
  end
end
