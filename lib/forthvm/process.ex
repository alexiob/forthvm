defmodule ForthVM.Process do
  alias ForthVM.PC
  alias ForthVM.Stack
  alias ForthVM.Dictionary
  alias ForthVM.Tokenizer

  @word_init "init"

  defstruct tokens: nil,
    stack: %Stack{},
    return_stack: %Stack{},
    dictionary: nil,
    last_word_name: nil,
    pc: %PC{},
    reductions: 0,
    status: nil,
    debug: false

  def new() do
    %__MODULE__{
      tokens: nil,
      stack: Stack.new(),
      return_stack: Stack.new(),
      dictionary: Dictionary.new(),
      last_word_name: nil,
      pc: nil,
      reductions: 0,
      status: :exec,
      debug: false
    }
  end

  def load(process = %__MODULE__{}, source, source_id) when is_binary(source) do
    load(process, Tokenizer.parse(source, source_id))
  end

  def load(process = %__MODULE__{dictionary: dictionary}, tokens) do
    debug_inspect(process, tokens, ">>> Process.tokens}")

    pc = PC.new(dictionary[@word_init])

    %{process | last_word_name: @word_init, pc: pc, tokens: tokens}
  end

  def next_token(process = %__MODULE__{tokens: [] }) do
    {process, nil}
  end

  def next_token(process = %__MODULE__{tokens: [token | tokens] }) do
    {%{process | tokens: tokens}, token}
  end

  def inc_pc(process = %__MODULE__{pc: pc}) do
    %{process | pc: PC.inc(pc)}
  end

  def set_pc(process = %__MODULE__{pc: pc}, idx) do
    %{process | pc: PC.set(pc, idx)}
  end

  def has_word?(process = %__MODULE__{}, name) when is_binary(name) do
    Map.has_key?(process.dictionary, name)
  end

  def get_word(process = %__MODULE__{}, name) when is_binary(name) do
    Map.get(process.dictionary, name)
  end

  def get_word(_process = %__MODULE__{}, _name) do
    nil
  end

  def push(process = %__MODULE__{stack: stack}, value) do
    # debug_inspect(process, stack, ">>> STACK.push = #{inspect(value)}")

    %{process | stack: Stack.push(stack, value)}
  end

  def pop(process = %__MODULE__{stack: stack}) do
    try do
      {value, stack} = Stack.pop(stack)
      # debug_inspect(process, stack, ">>> STACK.pop = #{inspect(value)}")

      {%{process | stack: stack}, value}
      rescue
      error ->
         IO.inspect(stack)
         reraise error, __STACKTRACE__
    end

  end

  def r_push(process = %__MODULE__{return_stack: stack}, value) do
    # debug_inspect(process, stack, ">>> RETURN_STACK.push = #{inspect(value)}")

    %{process | return_stack: Stack.push(stack, value)}
  end

  def r_pop(process = %__MODULE__{return_stack: stack}) do
    case Stack.depth(stack) do
      0 -> {process, nil}
      _ ->
        {value, stack} = Stack.pop(stack)

        # debug_inspect(process, stack, ">>> RETURN_STACK.pop = #{inspect(value)}")

        {%{process | return_stack: stack }, value}
    end
  end

  def exec(process = %__MODULE__{}, word) do
    case word do
      # an internal function, call it
      {function, %{type: :internal}} ->
        debug_inspect(process, function, "--> PROCESS.EXEC.function")

        function.(process)
      # a definition, execute it replacing the PC
      {word, %{type: :def}} ->
        debug_inspect(process, word, "--> PROCESS.EXEC.word")

        process |> r_push(process.pc) |> Map.put(:pc, PC.new(word))
    end
  end

  def set_debug(process = %__MODULE__{}, enabled) do
    %{process | debug: enabled}
  end

  def debug_trace(process = %__MODULE__{debug: show}, value) do
    process |> debug_trace(value, show)
  end

  def debug_trace(process = %__MODULE__{}, _value, false) do
    process
  end

  def debug_trace(process = %__MODULE__{}, value, true) do
    padding = 16
    IO.puts("<------------------------------ TRACE ------------------------------------")
    IO.inspect(value, label: String.pad_trailing("< word", padding), limit: :infinity)
    IO.inspect(process.last_word_name, label: String.pad_trailing("< last_word_name", padding), limit: :infinity)
    IO.inspect(process.return_stack, label: String.pad_trailing("< return_stack", padding), limit: :infinity)
    IO.inspect(process.pc, label: String.pad_trailing("< pc", padding), limit: :infinity)
    IO.inspect(process.pc && process.pc.idx, label: String.pad_trailing("< pc.idx", padding), limit: :infinity)
    IO.inspect(process.stack, label: String.pad_trailing("< stack", padding), limit: :infinity)
    IO.inspect(Map.get(process.dictionary, "forth_interpreter_flag", false), label: String.pad_trailing("< forth_interpret", padding), limit: :infinity)
    IO.puts("<-------------------------------------------------------------------------")

    process
  end

  def debug_puts(process = %__MODULE__{debug: true}, message) do
    IO.puts(message)

    process
  end

  def debug_puts(process = %__MODULE__{}, _message) do
    process
  end

  def debug_inspect(process = %__MODULE__{debug: true}, data, label) do
    IO.inspect(data, label: label)

    process
  end

  def debug_inspect(process = %__MODULE__{}, _data, _label) do
    process
  end
end
