defmodule ForthVM.Words.Interpreter do
  alias ForthVM.Process
  alias ForthVM.Token
  alias ForthVM.PC
  alias ForthVM.Words.Utils
  alias ForthVM.Dictionary

  @word_forth_interpret "forth_interpreter_flag"

  #=============================
  # branch operations
  #=============================

  def branch(process=%Process{pc: pc}) do
    {pc, idx} = PC.next(pc)

    Process.debug_puts(process, ">>> branch: pc=#{inspect(idx)}")

    %{process | pc: PC.inc(pc, Token.value(idx))}
  end

  def zbranch(process=%Process{pc: pc}) do
    {process, c} = Process.pop(process)
    value = Token.value(c)

    Process.debug_puts(process, ">>> 0branch.check: pc=#{pc.idx} c=#{c} branch? #{value == 0 or value == nil or value == false }")

    {pc, idx} = PC.next(pc)

    case value == 0 or value == nil or value == false do
      true ->
        Process.debug_puts(process, ">>> 0branch.jump: pc=#{pc.idx} to=#{inspect(idx)}")

        %{process | pc: PC.inc(pc, Token.value(idx))}
      false -> %{process | pc: pc}
    end
  end

  #=============================
  # variable manipulation
  #=============================

  def store(process=%Process{}) do
    {process, value, name} = Utils.pop2(process)

    Process.debug_puts(process, ">>> store: name=#{name} value=#{inspect(value)}")

    %{process | dictionary: Dictionary.set(process.dictionary, name, value)}
  end

  def fetch(process=%Process{}) do
    {process, name} = Process.pop(process)

    value = Map.get(process.dictionary, Token.value(name))

    Process.debug_puts(process, ">>> fatch: name=#{inspect(name)} value=#{inspect(value)}")

    process |> Process.push(value)
  end

  #=============================
  # control stack
  #=============================

  def to_r(process=%Process{}) do
    {process, value} = Process.pop(process)

    process |> Process.r_push(value)
  end

  def from_r(process=%Process{}) do
    {process, value} = Process.r_pop(process)

    process |> Process.push(value)
  end

  def drop_r(process=%Process{}) do
    {process, _value} = Process.r_pop(process)

    process
  end

  def exit(process=%Process{}) do
    Process.debug_inspect(process, process.pc, ">>> exit.pc.pre")

    {process, pc} = Process.r_pop(process)

    Process.debug_inspect(process, pc,  ">>> exit.pc.post")
    Process.debug_inspect(process, process.return_stack, ">>> exit.return_stack")

    %{process | pc: pc}
  end

  #=============================
  # interpreter related
  #=============================

  def next_token(process=%Process{}) do
    {process, token} = Process.next_token(process)

    Process.debug_inspect(process, token, ">>> next_token")

    process |> Process.push(Token.value(token))
  end

  @doc """
  Push next word token into the stack
  """
  def lit(process=%Process{pc: pc}) do
    {pc, token} = PC.next(pc)

    Process.debug_inspect(process, token, ">>> lit")

    %{process | pc: pc} |> Process.push(token)
  end

  @doc """
  Add a word to the latest created word, which must be a :def
  """
  def comma(process=%Process{dictionary: dictionary}) do
    {process, extra_word} = Process.pop(process)

    Process.debug_inspect(process, extra_word, ">>> comma[#{process.last_word_name}].extra_word")

    process = %{process | dictionary: Dictionary.append(dictionary, process.last_word_name, extra_word)}

    Process.debug_inspect(process, process.dictionary[process.last_word_name], ">>> comma[#{process.last_word_name}].word")
  end

  def left_bracket(process=%Process{dictionary: dictionary}) do
    Process.debug_puts(process, ">>> left_bracket: forth_interpret=true")

    %{process | dictionary: Dictionary.set(dictionary, @word_forth_interpret, true)}
  end


  def right_bracket(process=%Process{dictionary: dictionary}) do
    Process.debug_puts(process, ">>> right_bracket: forth_interpret=false")

    %{process | dictionary: Dictionary.set(dictionary, @word_forth_interpret, false)}
  end

  def forth_interpret(process=%Process{dictionary: dictionary}) do
    Process.debug_puts(process, ">>> forth_interpret: forth_interpret=#{Map.get(dictionary, @word_forth_interpret, false)}")

    Process.push(process, Map.get(dictionary, @word_forth_interpret, false))
  end

  def is_immediate(process=%Process{}) do
    {process, {word, %{mode: mode}} = meta} = Process.pop(process)

    Process.debug_inspect(process, word, ">>> is_immediate: #{mode == :immediate} #{inspect(meta)}")

    Process.push(process, mode == :immediate)
  end

  def word_from_name(process=%Process{}) do
    {process, name} = Process.pop(process)

    word = Process.get_word(process, name)
    is_word = Dictionary.is_word?(word)
    value = if is_word, do: word, else: name

    Process.debug_inspect(process, word, ">>> word_from_name[#{name}] is_word=#{is_word} value=#{inspect(value)}")

    process
    |> Process.push(value)
    |> Process.push(is_word)
  end

  def create(process=%Process{dictionary: dictionary}) do
    {process, name} = Process.pop(process)

    Process.debug_puts(process, ">>> create: name=#{inspect(name)}")

    %{process | dictionary: Dictionary.add(dictionary, name, []), last_word_name: name}
  end

  def immediate(process=%Process{dictionary: dictionary}) do
    {code, meta} = Process.get_word(process, process.last_word_name)
    word = {code, %{meta | mode: :immediate}}

    Process.debug_puts(process, ">>> immediate: last_word_name=#{process.last_word_name}")

    %{process | dictionary: Map.put(dictionary, process.last_word_name, word)}
  end

  def exec(process=%Process{}) do
    {process, word} = Process.pop(process)

    Process.debug_puts(process, ">>> exec: word=#{inspect(word)}")

    Process.exec(process, word)
  end

  def nop(process=%Process{}) do
    process
  end

  def debug_enable(process=%Process{}) do
    process |> Process.set_debug(true)
  end

  def debug_disable(process=%Process{}) do
    process |> Process.set_debug(false)
  end

  def debug_process_trace(process=%Process{}) do
    {process, value} = Process.pop(process)

    process |> Process.debug_trace(value, true)
  end

  def debug_word_dump(process=%Process{}) do
    {process, name} = Process.pop(process)
    name = String.trim(name, "'")
    {code, meta} = case Process.get_word(process, name) do
      nil -> {:undefined, :undefined}
      word -> word
    end

    padding = 16
    IO.puts("<------------------------------ WORD ------------------------------------")
    IO.inspect(name, label: String.pad_trailing("< name", padding))
    IO.inspect(meta, label: String.pad_trailing("< meta", padding))
    IO.inspect(code, label: String.pad_trailing("< code", padding))
    if code == :undefined do
      IO.inspect(process.dictionary, label: String.pad_trailing("< dictionary", padding), limit: :infinity)
    end
    IO.puts("<-------------------------------------------------------------------------")

    process
  end

  def interpret(process=%Process{}) do
    # enter forth_interpret mode
    # :loop
    # word_name = get the next token
    # if word_name == nil: goto :exit
    # word = get word definition
    # if word == nil: goto :lit
    # if word is immediate or forth_interpret mode: execute, goto :loop
    # else add word to last_word, goto :loop
    # :lit
    # if forth_interpret: goto :loop
    # put next token into stack, immediate
    # put next token into stack
    # add token in stack into last word
    # add token in stack into last word, again
    # goto :loop
    # :exit
    # drop from stack
    # exit => pop the return stack and set tit as the active PC
    process
  end
end
