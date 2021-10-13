defmodule ForthVM.Core.Dictionary do
  #---------------------------------------------
  # Dictionary utilities
  #---------------------------------------------

  def get(dictionary, word_name) do
    case Map.has_key?(dictionary, word_name) do
      true -> dictionary[word_name]
      false -> {:unknown_word, word_name}
    end
  end

  def add(dictionary, word_name, word, doc \\ %{ stack: "( )", doc: ""}) when is_list(word) or is_function(word) do
    Map.put(dictionary, word_name, {:word, word, doc})
  end

  def add_var(dictionary, word_name, value \\ nil) do
    Map.put(dictionary, word_name, {:var, value})
  end

  def set_var(dictionary, word_name, value) do
    Map.put(dictionary, word_name, {:var, value})
  end

  def get_var(dictionary, word_name) do
    {:var, value} = Map.get(dictionary, word_name, {:var, :undefined})
    value
  end

  @spec add_const(map, any, any) :: map
  def add_const(dictionary, word_name, value) do
    Map.put(dictionary, word_name, {:const, value})
  end

  def new() do
    dictionary = %{}

    word_modules = [
      ForthVM.Words.Flow,
      ForthVM.Words.Interpreter,
      ForthVM.Words.IO,
      ForthVM.Words.Logic,
      ForthVM.Words.Math,
      ForthVM.Words.Stack,
      ForthVM.Words.String,
    ]

    Enum.reduce(word_modules, dictionary, &register_module_words/2)
  end

  @doc """
  Automatically register all module's functions that have a doc matching "{word_name}: ({in} -- {out}) {doc}"
  """
  def register_module_words(module, dictionary) do
    {_, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)

    docs
    |> Enum.reduce(dictionary, fn(doc, dict) -> register_module_word_from_doc(module, doc, dict) end)
  end

  def register_module_word_from_doc(module, {{:function, function, arity}, _, [_header], %{"en" => doc}, _}, dictionary) when is_binary(doc) do
    %{"doc" => word_doc, "name" => word_name, "stack" => word_stack} = Regex.named_captures(~r/^\s*(?<name>.+)\s*\:\s*(?<stack>\([^)]*\))+\s*(?<doc>.*)?$/, doc)

    word_name = cond do
      Regex.match?(~r/^\"(.*)\"$/, word_name) -> String.trim(word_name, "\"")
      true -> word_name
    end

    IO.puts(">>> CAPTURING: #{function}:#{arity} -> name=#{word_name} stack=#{word_stack} doc=#{word_doc}")
    add(dictionary, word_name, Function.capture(module, function, arity), %{stack: word_stack, doc: word_doc})
  end
  def register_module_word_from_doc(_module, doc, dictionary) do
    IO.inspect(doc, label: ">>> IGNORED WORD DEF")
    dictionary
  end

end
