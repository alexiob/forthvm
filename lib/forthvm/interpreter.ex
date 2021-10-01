defmodule ForthVM.Interpreter do
  alias ForthVM.Process
  alias ForthVM.PC

  def interpret(process = %Process{}, reductions) do
    exec_reduction({:exec, process, nil}, reductions)
  end

  # no more available reductions, suspend execution, but keep PC
  def exec_reduction({_interpreter_command, process = %Process{reductions: vm_reductions}, _value}, reductions) when vm_reductions == reductions do
    Process.debug_inspect(process, process.stack, ">>> exec_reduction.no_more_reductions")

    %{process | reductions: 0}
  end

  # program finished, suspend execution, reset PC
  def exec_reduction({:halt = status, process = %Process{pc: pc}, _value}, _reductions) do
    Process.debug_inspect(process, process.stack, ">>> exec_reduction.halt")
    %{process | status: status, pc: PC.set(pc, 0), reductions: 0}
  end

  def exec_reduction({:exec, process = %Process{status: :exec}, _value}, reductions) do
    # IO.puts(">>> exec_reduction.exec: PC=#{process.pc.idx} Reduction=#{process.reductions} Status=#{process.status}")
    # IO.inspect(process.stack, label: ">>> exec_reduction.exec")

    process
    |> process_token()
    # |> tap(fn ({_, process, value}) -> Process.debug_trace(process, value) end)
    |> next_reduction()
    |> exec_reduction(reductions)
  end

  def next_reduction({:halt, process = %Process{}, nil}) do
    {:halt, process, nil}
  end

  def next_reduction({:exec, process = %Process{reductions: reductions}, _value}) do
    {:exec, %{process | reductions: reductions + 1}, nil}
  end

  def next_reduction({:halt, process = %Process{}, nil}, _value) do
    {:halt, process, nil}
  end

  def process_token(process = %Process{pc: pc}) do
    {pc, token} = PC.next(pc)

    # IO.inspect(token, label: "! process_token.token")

    process_token(%{process | pc: pc}, token)
  end

  def process_token(process = %Process{}, nil) do
    {:halt, process, nil}
  end

  def process_token(process = %Process{}, {function, _meta} = word) when is_function(function) do
    {:exec, Process.exec(process, word), word}
  end

  def process_token(process = %Process{}, {:string, _meta, value}) do
    # IO.inspect(process.stack, label: ">>> process_token.pre")
    # IO.puts(">>> process_token(:string, #{value})")

    process = process_word(process, value)

    # IO.inspect(process.stack, label: ">>> process_token.post")

    {:exec, process, value}
  end

  def process_token(process = %Process{}, {:integer, _meta, value}) do
    # IO.inspect(process.stack, label: ">>> process_token.integer")
    # IO.puts(">>> process_token(:integer, #{value})")

    {:exec, Process.push(process, value), value}
  end

  def process_token(process = %Process{}, {:float, _meta, value}) do
    # IO.inspect(process.stack, label: ">>> process_token.float")
    # IO.puts(">>> process_token(:float, #{value})")

    {:exec, Process.push(process, value), value}
  end

  def process_token(process, name) when is_binary(name) do
    # IO.puts(">>> process_token.name: #{name}")

    process = process_word(process, name)

    {:exec, process, name}
  end

  def process_token(process, token) do
    # IO.puts(">>> process_token.unknown")
    # IO.inspect(token)

    {:exec, process, token}
  end

  def process_word(process = %Process{dictionary: dictionary}, name) do
    # IO.inspect(name, label: "! process_word")
    case Map.get(dictionary, name) do
      # not a word, push into the stack
      nil -> Process.push(process, name)
      word -> Process.exec(process, word)
    end
  end
end
