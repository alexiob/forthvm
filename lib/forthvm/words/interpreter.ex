defmodule ForthVM.Words.Interpreter do
  import ForthVM.Utils

  alias ForthVM.Process
  alias ForthVM.Dictionary
  alias ForthVM.Tokenizer

  # ---------------------------------------------
  # Process exit conditions
  # ---------------------------------------------

  @doc """
  end: ( -- ) ( R: -- ) explicit process termination
  """
  def _end(_tokens, data_stack, return_stack, dictionary, meta) do
    Process.next([], data_stack, return_stack, dictionary, meta)
  end

  @doc """
  abort: ( i * x -- ) ( R: j * x -- ) empty the data stack and perform the function of QUIT, which includes emptying the return stack, without displaying a message.
  """
  def abort(_tokens, _data_stack, _return_stack, dictionary, meta) do
    Process.next([], [], [], dictionary, meta)
  end

  @doc """
  abort?: ( flag i * x -- ) ( R: j * x -- ) if flag is truthly empty the data stack and perform the function of QUIT, which includes emptying the return stack, displaying a message.
  """
  def abort_msg([message | tokens], [flag | data_stack], return_stack, dictionary, meta) do
    if is_truthly(flag) do
      IO.puts(meta.io.device, message)
      abort(tokens, data_stack, return_stack, dictionary, meta)
    else
      Process.next(tokens, data_stack, return_stack, dictionary, meta)
    end
  end

  # ---------------------------------------------
  # Sleep
  # ---------------------------------------------

  @doc """
  sleep: ( x -- ) sleep for given milliseconds
  """
  def sleep(tokens, [ms | data_stack], return_stack, dictionary, meta) do
    till = System.monotonic_time() + System.convert_time_unit(ms, :millisecond, :native)
    Process.next(tokens, data_stack, return_stack, dictionary, %{meta | sleep: till})
  end

  # ---------------------------------------------
  # Comments
  # ---------------------------------------------

  @doc """
  "(": ( -- ) discard all tokens till ")" is fountd
  """
  def comment(tokens, data_stack, return_stack, dictionary, meta) do
    {_comment_tokens, [")" | tokens]} = Enum.split_while(tokens, fn s -> s != ")" end)

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  # ---------------------------------------------
  # Word definition
  # ---------------------------------------------

  @doc """
  ":": ( -- ) convert all tokens till ";" is found into a new word
  """
  def create([word_name | tokens], data_stack, return_stack, dictionary, meta) do
    # FIXME: implement `is-interpret` and `immediate`
    {word_tokens, [";" | tokens]} = Enum.split_while(tokens, fn s -> s != ";" end)

    Process.next(
      tokens,
      data_stack,
      return_stack,
      Dictionary.add(dictionary, word_name, word_tokens),
      meta
    )
  end

  @doc """
  variable: ( -- ) create a new variable with name from next token
  """
  def variable([word_name | tokens], data_stack, return_stack, dictionary, meta) do
    dictionary =
      case Map.has_key?(dictionary, word_name) do
        true -> dictionary
        false -> Dictionary.add_var(dictionary, word_name, nil)
      end

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  "!": ( x name -- ) store value in variable
  """
  def set_variable(tokens, [word_name, x | data_stack], return_stack, dictionary, meta) do
    case Map.has_key?(dictionary, word_name) do
      false ->
        raise("can not set unknown variable '#{word_name}' with value '#{inspect(x)}'")

      true ->
        Process.next(
          tokens,
          data_stack,
          return_stack,
          Dictionary.set_var(dictionary, word_name, x),
          meta
        )
    end
  end

  @doc """
  "+!": ( x name -- ) increment variable by given value
  """
  def inc_variable(tokens, [word_name, x | data_stack], return_stack, dictionary, meta) do
    case Map.has_key?(dictionary, word_name) do
      false ->
        raise("can not increment unknown variable '#{word_name}' by '#{inspect(x)}'")

      # FIXME: should handle :undefined ?
      true ->
        Process.next(
          tokens,
          data_stack,
          return_stack,
          Dictionary.set_var(
            dictionary,
            word_name,
            Dictionary.get_var(dictionary, word_name) + x
          ),
          meta
        )
    end
  end

  @doc """
  "@": ( name -- ) get value in variable
  """
  def get_variable(tokens, [word_name | data_stack], return_stack, dictionary, meta) do
    case Map.has_key?(dictionary, word_name) do
      false ->
        raise("can not fetch unknown variable '#{word_name}'")

      true ->
        Process.next(
          tokens,
          [Dictionary.get_var(dictionary, word_name) | data_stack],
          return_stack,
          dictionary,
          meta
        )
    end
  end

  @doc """
  constant: ( x -- ) create a new costant with name from next token and value from data stack
  """
  def constant([word_name | tokens], [x | data_stack], return_stack, dictionary, meta) do
    case Map.has_key?(dictionary, word_name) do
      true ->
        raise(
          "can not set already defined constant '#{word_name}' with new value '#{inspect(x)}'"
        )

      false ->
        Process.next(
          tokens,
          data_stack,
          return_stack,
          Dictionary.add_const(dictionary, word_name, x),
          meta
        )
    end
  end

  @doc """
  include: ( -- ) include program file from filename specified in next token.
  """
  def include([filename | tokens], data_stack, return_stack, dictionary, meta) do
    case File.read(filename) do
      {:ok, source} ->
        Process.next(
          Tokenizer.parse(source) ++ tokens,
          data_stack,
          return_stack,
          dictionary,
          meta
        )

      {:error, file_error} ->
        raise("can not include '#{filename}' because '#{inspect(file_error)}'")
    end
  end
end
