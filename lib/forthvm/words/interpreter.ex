defmodule ForthVM.Words.Interpreter do
  import ForthVM.Core.Utils

  alias ForthVM.Core
  alias ForthVM.Core.Dictionary

  #---------------------------------------------
  # Process exit conditions
  #---------------------------------------------

  @doc"""
  end: ( -- ) ( R: -- ) explicit process termination
  """
  def _end(_tokens, data_stack, return_stack, dictionary, meta) do
    Core.next([], data_stack, return_stack, dictionary, meta)
  end

  @doc"""
  abort: ( i * x -- ) ( R: j * x -- ) empty the data stack and perform the function of QUIT, which includes emptying the return stack, without displaying a message.
  """
  def abort(_tokens, _data_stack, _return_stack, dictionary, meta) do
    Core.next([], [], [], dictionary, meta)
  end

  @doc"""
  abort": ( flag i * x -- ) ( R: j * x -- ) if flag is truthly empty the data stack and perform the function of QUIT, which includes emptying the return stack, displaying a message.
  """
  def abort_msg(tokens, [flag | data_stack], return_stack, dictionary, meta) do
    {message, ["\"" | tokens]} = Enum.split_while(tokens, fn s -> s != "\"" end)
    if is_truthly(flag) do
      # FIXME: use VM IO functions
      message = Enum.join(message, " ")
      IO.puts(message)
      abort(tokens, data_stack, return_stack, dictionary, meta)
    else
      Core.next(tokens, data_stack, return_stack, dictionary, meta)
    end
  end

  #---------------------------------------------
  # Word definition
  #---------------------------------------------

  @doc"""
  ":": ( -- ) convert all tokens till ";" is fount into a new word
  """
  def create([word_name | tokens], data_stack, return_stack, dictionary, meta) do
    {word_tokens, [";" | tokens]} = Enum.split_while(tokens, fn s -> s != ";" end)

    Core.next(tokens, data_stack, return_stack, Dictionary.add(dictionary, word_name, word_tokens), meta)
  end

  @doc"""
  variable: ( -- ) create a new variable
  """
  def variable([word_name | tokens], data_stack, return_stack, dictionary, meta) do
    dictionary = case Map.has_key?(dictionary, word_name) do
      true -> dictionary
      false -> Dictionary.add_var(dictionary, word_name, nil)
    end

    Core.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc"""
  "!": ( name x -- ) store value in variable
  """
  def set_variable(tokens, [word_name, x | data_stack], return_stack, dictionary, meta) do
    dictionary = case Map.has_key?(dictionary, word_name) do
      # FIXME: should raise an error
      false -> dictionary
      true -> Dictionary.set_var(dictionary, word_name, x)
    end

    Core.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc"""
  "+!": ( name x -- ) increment variable by given value
  """
  def inc_variable(tokens, [word_name, x | data_stack], return_stack, dictionary, meta) do
    dictionary = case Map.has_key?(dictionary, word_name) do
      # FIXME: should raise an error
      false -> dictionary
      # FIXME: should handle :undefined ?
      true -> Dictionary.set_var(dictionary, word_name, Dictionary.get_var(dictionary, word_name) + x)
    end

    Core.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc"""
  "@": ( name -- ) get value in variable
  """
  def get_variable(tokens, [word_name | data_stack], return_stack, dictionary, meta) do
    dictionary = case Map.has_key?(dictionary, word_name) do
      # FIXME: should raise an error
      false -> dictionary
      true -> Dictionary.get_var(dictionary, word_name)
    end

    Core.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc"""
  constant: ( x -- ) create a new costant
  """
  def constant([word_name | tokens], [x | data_stack], return_stack, dictionary, meta) do
    dictionary = case Map.has_key?(dictionary, word_name) do
      # FIXME: should raise an error
      true -> dictionary
      false -> Dictionary.add_const(dictionary, word_name, x)
    end

    Core.next(tokens, data_stack, return_stack, dictionary, meta)
  end
end
