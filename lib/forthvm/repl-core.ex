defmodule ForthVM.Repl.Core do
  @moduledoc """
  Multiprocess REPL
  """
  # alias ForthVM.Core
  # alias ForthVM.Dictionary
  # alias ForthVM.Tokenizer

  # @prompt ">> "
  # @reductions 100

  # def context() do
  #   {[], [], [], Dictionary.new(), Process.new_meta()}
  # end

  # def run() do
  #   Core.new()
  #   |> Core.spawn_process("repl")
  #   |> loop(repl)
  # end

  # def loop(state) do
  #   input = IO.gets(@prompt)
  #   tokens = Tokenizer.parse(input)

  #   loop(process(tokens, state))
  # end

  # def process(command_tokens, {core, repl_process})
  #     when is_list(command_tokens) do
  #   # process({command_tokens ++ tokens, data_stack, return_stack, dictionary, meta})
  # end

  # def process(context) do
  #   case Process.run(context, @reductions) do
  #     {:exit, context, value} ->
  #       if value != nil do
  #         IO.inspect(value)
  #       end

  #       loop(context)

  #     {:error, context, message} ->
  #       IO.puts("> Error #{message}")

  #       loop(context)

  #     {:yield, context, _} ->
  #       process(context)
  #   end
  # end
end
