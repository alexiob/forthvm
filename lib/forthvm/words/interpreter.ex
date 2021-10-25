defmodule ForthVM.Words.Interpreter do
  @moduledoc """
  Interpreter words
  """

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

  # ---------------------------------------------
  # Debug
  # ---------------------------------------------

  @doc """
  debug-enable: ( -- ) set process debug flag to true.
  """
  def debug_enable(tokens, data_stack, return_stack, dictionary, meta) do
    Process.next(tokens, data_stack, return_stack, dictionary, %{meta | debug: true})
  end

  @doc """
  debug-disable: ( -- ) set process debug flag to false.
  """
  def debug_disable(tokens, data_stack, return_stack, dictionary, meta) do
    Process.next(tokens, data_stack, return_stack, dictionary, %{meta | debug: false})
  end

  @doc """
  inspect: ( -- ) prints process contex: tokens, data stack, return stack, dictionary, meta.
  """
  def inspec(tokens, data_stack, return_stack, dictionary, meta) do
    io = meta.io.device

    IO.puts(io, "<------------------------------ INSPECT ------------------------------------")
    IO.puts(io, "Remaining instructions:")
    IO.inspect(io, tokens, limit: :infinity)
    IO.puts(io, "Data stack:")
    IO.inspect(io, data_stack, limit: :infinity)
    IO.puts(io, "Return stack:")
    IO.inspect(io, return_stack, limit: :infinity)
    IO.puts(io, "Dictionary:")
    IO.inspect(io, dictionary, limit: :infinity)
    IO.puts(io, "Meta:")
    IO.inspect(io, meta, limit: :infinity)
    IO.puts(io, "<---------------------------------------------------------------------------")

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  debug-dump-word: ( -- ) prints the definition of the word specified in the next token.
  """
  def debug_dump_word([word_name | tokens], data_stack, return_stack, dictionary, meta) do
    io = meta.io.device

    {type, code, doc} = dump_word(ForthVM.Dictionary.get(dictionary, word_name))

    padding = 16
    IO.puts(io, "<--------------------------------- WORD ------------------------------------")
    IO.inspect(io, word_name, label: String.pad_trailing("< name", padding))
    IO.inspect(io, type, label: String.pad_trailing("< type", padding))

    if is_map(doc) do
      if Map.get(doc, :stack) do
        IO.inspect(io, doc.stack, label: String.pad_trailing("< stack", padding))
      end

      if Map.get(doc, :doc) do
        IO.inspect(io, doc.doc, label: String.pad_trailing("< doc", padding))
      end
    end

    IO.inspect(io, code, label: String.pad_trailing("< def", padding))
    IO.puts(io, "<---------------------------------------------------------------------------")

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  # ---------------------------------------------
  # PRIVATE
  # ---------------------------------------------

  defp dump_word({:word, function, meta}) when is_function(function) do
    # functions
    {"function", function, Map.get(meta, :doc)}
  end

  defp dump_word({:word, word_tokens, meta}) when is_list(word_tokens) do
    # tokens
    {"word", word_tokens, Map.get(meta, :doc)}
  end

  defp dump_word({:var, value}) do
    # variable
    {"var", value, nil}
  end

  defp dump_word({:const, value}) do
    # constant
    {"const", value, nil}
  end

  defp dump_word({:unknown_word, value}) do
    # unknown
    {"unknown", value, nil}
  end

  defp dump_word(invalid) do
    # invalid: should never happen
    {"unknown", inspect(invalid, limit: :infinity), nil}
  end
end
