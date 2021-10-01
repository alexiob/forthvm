defmodule ForthVM.Dictionary do
  alias ForthVM.Tokenizer
  alias ForthVM.Words.Stack
  alias ForthVM.Words.Interpreter
  alias ForthVM.Words.Arithmetic
  alias ForthVM.Words.Bits
  alias ForthVM.Words.Logic
  alias ForthVM.Words.Comparison
  alias ForthVM.Words.IO

  def new do
    %{}
    # stack
    |> add("dup", &Stack.dup/1, :runtime)
    |> add("drop", &Stack.drop/1, :runtime)
    |> add("swap", &Stack.swap/1, :runtime)
    |> add("over", &Stack.over/1, :runtime)
    |> add("rot", &Stack.rot/1, :runtime)
    |> add("depth", &Stack.depth/1, :runtime)
    |> add("pick", &Stack.pick/1, :runtime)
    # arithmetics
    |> add("+", &Arithmetic.add/1, :runtime)
    |> add("-", &Arithmetic.sub/1, :runtime)
    |> add("*", &Arithmetic.mult/1, :runtime)
    |> add("/", &Arithmetic.div/1, :runtime)
    |> add("/mod", &Arithmetic.div_mod/1, :runtime)
    # bits
    |> add("&", &Bits.b_and/1, :runtime)
    |> add("|", &Bits.b_or/1, :runtime)
    |> add("^", &Bits.b_xor/1, :runtime)
    |> add("~", &Bits.b_not/1, :runtime)
    |> add("<<", &Bits.b_shift_left/1, :runtime)
    |> add(">>", &Bits.b_shift_right/1, :runtime)
    # logic
    |> add("and", &Logic.l_and/1, :runtime)
    |> add("or", &Logic.l_or/1, :runtime)
    |> add("not", &Logic.l_not/1, :runtime)
    # comparison
    |> add("<=", &Comparison.le/1, :runtime)
    |> add("<", &Comparison.lt/1, :runtime)
    |> add(">=", &Comparison.ge/1, :runtime)
    |> add("<", &Comparison.gt/1, :runtime)
    |> add("=", &Comparison.eq/1, :runtime)
    |> add("<>", &Comparison.ne/1, :runtime)
    # IO
    |> add("puts", &IO.puts/1, :runtime)
    |> add("inspect", &IO.inspect/1, :runtime)
    # branch
    |> add("branch", &Interpreter.branch/1, :runtime)
    |> add("0branch", &Interpreter.zbranch/1, :runtime)
    # variables
    |> add("!", &Interpreter.store/1, :runtime)
    |> add("@", &Interpreter.fetch/1, :runtime)
    # return stack
    |> add(">r", &Interpreter.to_r/1, :runtime)
    |> add("r>", &Interpreter.from_r/1, :runtime)
    |> add("rdrop", &Interpreter.drop_r/1, :runtime)
    |> add("exit", &Interpreter.exit/1, :runtime)
    # debug
    |> add("debug-process-trace", &Interpreter.debug_process_trace/1, :immediate)
    |> add("debug-word-dump", &Interpreter.debug_word_dump/1, :immediate)
    |> add("debug-enable", &Interpreter.debug_enable/1, :immediate)
    |> add("debug-disable", &Interpreter.debug_disable/1, :immediate)
    # interpreter
    |> add("next-token", &Interpreter.next_token/1, :runtime)
    |> add("lit", &Interpreter.lit/1, :runtime)
    |> add("tick", &Interpreter.lit/1, :immediate)
    |> add(",", &Interpreter.comma/1, :immediate)
    |> add("[", &Interpreter.left_bracket/1, :immediate)
    |> add("]", &Interpreter.right_bracket/1, :immediate)
    |> add("forth-interpret", &Interpreter.forth_interpret/1, :runtime)
    |> add("is-immediate", &Interpreter.is_immediate/1, :runtime)
    |> add("word-from-name", &Interpreter.word_from_name/1, :runtime)
    |> add("create", &Interpreter.create/1, :runtime)
    |> add("immediate", &Interpreter.immediate/1, :runtime)
    |> add("exec", &Interpreter.exec/1, :runtime)
    |> add("nop", &Interpreter.nop/1, :runtime)
    |> add("end", nil, :runtime)
    |> add("bye", ["end"], :runtime)
    |> add(":", ["next-token", "create", "]", "exit"], :immediate)
    |> add(";", ["lit", "exit", ",", "[", "exit"], :immediate)
    # |> add(";", ["nop", "exit", "nop", "[", "exit"], :immediate)
    |> add("interpret", [
      "[",
      # ini
      "next-token",                        # 0
      "dup", "0branch", 26,          # 1  --> exit
      "word-from-name",              # 4
      "0branch", 12,                 # 5  --> lit
      # is_word
      "dup", "is-immediate",         # 7
      "forth-interpret",             # 9
      "or", "0branch", 3,            # 10 --> wd_compile
      # wd_interpret
      "exec", "branch", -16,         # 13 --> ini
      # wd_compile
      ",", "branch", -19,            # 16 --> ini
      # lit
      "forth-interpret",             # 19
      "0branch", 2,                  # 20 --> lit_complie
      # lit interpret
      "branch", -24,                 # 22 --> ini
      # lit compile
      "tick", "lit", ",", ",",          # 24
      "branch", -30,                 # 28 --> ini
      # exit
      "drop", "exit"                 # 30
    ], :runtime)
    |> add("init", ["interpret", "exit"], :runtime)
  end

  def add(dictionary = %{}, name, "true") do
    Map.put(dictionary, name, {true, %{ mode: nil, type: :value }})
  end

  def add(dictionary = %{}, name, "false") do
    Map.put(dictionary, name, {false, %{ mode: nil, type: :value }})
  end

  def add(dictionary = %{}, name, value) when is_boolean(value) or is_binary(value) or is_number(value) do
    Map.put(dictionary, name, {value, %{ mode: nil, type: :value }})
  end

  def add(dictionary = %{}, name, function) do
    add(dictionary, name, function, :runtime)
  end

  def add(dictionary = %{}, name, function, mode) when is_function(function) or is_nil(function) do
    Map.put(dictionary, name, {function, %{ mode: mode, type: :internal }})
  end

  def add(dictionary = %{}, name, words, mode) when is_list(words) do
    Map.put(dictionary, name, {A.Vector.new(Tokenizer.parse(words, name)), %{ mode: mode, type: :def }})
  end

  def add(dictionary = %{}, name, words = %A.Vector{}, mode) do
    Map.put(dictionary, name, {words, %{ mode: mode, type: :def }})
  end

  def append(dictionary = %{}, name, extra_word) do
    {words, meta} = Map.get(dictionary, name)

    case words do
      nil -> dictionary
      words -> Map.put(dictionary, name, {A.Vector.append(words, extra_word), meta})
    end
  end

  def is_word?({_function, %{ mode: _mode, type: _type }}), do: true
  def is_word?(_), do: false

  def is_immediate?({_function, %{ mode: :immediate, type: _type }}), do: true
  def is_immediate?(_), do: false

  def set(dictionary = %{}, name, value) do
    Map.put(dictionary, name, value)
  end

end
