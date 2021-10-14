defmodule ForthVM.Core do
  import ForthVM.Core.Utils

  #---------------------------------------------
  # Custom guards
  #---------------------------------------------

  def new_meta() do
    %{
      reductions: 0,
      debug: false,
      io: %{
        device: :stdio,
        devices: %{
          "stdio" => :stdio
        }
      }
    }
  end

  #---------------------------------------------
  # Entry points
  #---------------------------------------------

  # run program described by tokens, using the provided dictionary, for, at max, number of reductions
  def run(tokens, dictionary = %{}, reductions) do
    process(tokens, [], [], dictionary, %{new_meta() | reductions: reductions})
  end

  # run program defined in the provided context, for, at max, number of reductions
  def run({tokens, data_stack, return_stack, dictionary, meta}, reductions) do
    process(tokens, data_stack, return_stack, dictionary, %{meta | reductions: reductions})
  end

  #---------------------------------------------
  # Handle next processing step
  #---------------------------------------------

  @doc """
  Mainly used handle reduction-driven processing
  """
  def next(tokens, data_stack, return_stack, dictionary, meta)

  # process consumed all available reductions
  def next(tokens, data_stack, return_stack, dictionary, %{reductions: 0} = meta) do
    {:yield, {tokens, data_stack, return_stack, dictionary, meta}, nil}
  end

  def next(tokens, data_stack, return_stack, dictionary, %{reductions: reductions} = meta) do
    process(tokens, data_stack, return_stack, dictionary, %{meta | reductions: reductions - 1})
  end

  #---------------------------------------------
  # Handle exit
  #---------------------------------------------

  def exit(tokens, data_stack, return_stack, dictionary, meta, exit_value) do
    {:exit, {tokens, data_stack, return_stack, dictionary, meta}, exit_value}
  end

  #---------------------------------------------
  # Dictionary utilities
  #---------------------------------------------

  defp get_dictionary_word(dictionary, word_name) do
    case Map.has_key?(dictionary, word_name) do
      true -> dictionary[word_name]
      false -> {:unknown_word, word_name}
    end
  end

  #---------------------------------------------
  # Process instructions
  #---------------------------------------------

  @doc """
  Process a core word.
  """
  def process(tokens, data_stack, return_stack, dictionary, meta)

  #---------------------------------------------
  # Process exit conditions
  #---------------------------------------------

  # no more tokens, one last value in the data stack
  def process([], [last_value], return_stack, dictionary, meta) do
    exit([], [], return_stack, dictionary, meta, last_value)
  end

  # no more tokens or data
  def process([], [], return_stack, dictionary, meta) do
    exit([], [], return_stack, dictionary, meta, nil)
  end

  # no more tokens but data in the stack
  def process([], data_stack, return_stack, dictionary, meta) do
    exit([], data_stack, return_stack, dictionary, meta, data_stack)
  end

  # # word: end
  # def process(["end" | _ ], data_stack, return_stack, dictionary, meta) do
  #   next([], data_stack, return_stack, dictionary, meta)
  # end

  #---------------------------------------------
  # Debug
  #---------------------------------------------

  def process(["debug-enable" | tokens ], data_stack, return_stack, dictionary, meta) do
    next(tokens, data_stack, return_stack, dictionary, %{meta | debug: true})
  end

  def process(["debug-disable" | tokens ], data_stack, return_stack, dictionary, meta) do
    next(tokens, data_stack, return_stack, dictionary, %{meta | debug: false})
  end

  def process(["debug-dump-word", word_name | tokens], data_stack, return_stack, dictionary, meta) do
    {type, code, doc} = case get_dictionary_word(dictionary, word_name) do
      # function: execute function
      {:word, function, meta} when is_function(function) -> {"function", function, Map.get(meta, :doc)}
      # tokens
      {:word, word_tokens, meta} when is_list(word_tokens) -> {"word", word_tokens, Map.get(meta, :doc)}
      # variable
      {:var, value} -> {"var", value, nil}
      # constant
      {:const, value} -> {"const", value, nil}
      # unknown
      {:unknown_word, value} -> {"unknown", value, nil}
      # invalid: should never happen
      invalid -> {"unknown", inspect(invalid, limit: :infinity), nil}
    end

    padding = 16
    IO.puts("<--------------------------------- WORD ------------------------------------")
    IO.inspect(word_name, label: String.pad_trailing("< name", padding))
    IO.inspect(type, label: String.pad_trailing("< type", padding))
    if is_map(doc) do
      if Map.get(doc, :stack) do
        IO.inspect(doc.stack, label: String.pad_trailing("< stack", padding))
      end
      if Map.get(doc, :doc) do
        IO.inspect(doc.doc, label: String.pad_trailing("< doc", padding))
      end
    end
    IO.inspect(code, label: String.pad_trailing("< def", padding))
    IO.puts("<---------------------------------------------------------------------------")

    next(tokens, data_stack, return_stack, dictionary, meta)
  end

  def process(["inspect" | tokens ], data_stack, return_stack, dictionary, meta) do
    IO.puts("<------------------------------ INSPECT ------------------------------------")
    IO.puts("Remaining instructions:")
    IO.inspect(tokens, limit: :infinity)
    IO.puts("Data stack:")
    IO.inspect(data_stack, limit: :infinity)
    IO.puts("Return stack:")
    IO.inspect(return_stack, limit: :infinity)
    IO.puts("Dictionary:")
    IO.inspect(dictionary, limit: :infinity)
    IO.puts("Meta:")
    IO.inspect(meta, limit: :infinity)
    IO.puts("<---------------------------------------------------------------------------")

    next(tokens, data_stack, return_stack, dictionary, meta)
  end

  #---------------------------------------------
  # Flow control: if_condition IF if_stack [ELSE else_stack] THEN
  #---------------------------------------------

  # CLOSING CONDITIONS

  # there is an if/else clause on top or return_stack AND if_condition is FALSELY
  def process(["then" | tokens ], data_stack, [if_condition, %{if: _if_stack, else: else_stack} | return_stack], dictionary, meta) when is_falsely(if_condition) do
    next(dump_stack_onto_stack(else_stack, tokens), data_stack, return_stack, dictionary, meta)
  end

  # there is an if/else clause on top or return_stack AND if_condition is TRUTHLY
  def process(["then" | tokens ], data_stack, [if_condition, %{if: if_stack, else: _else_stack} | return_stack], dictionary, meta) when is_truthly(if_condition) do
    next(dump_stack_onto_stack(if_stack, tokens), data_stack, return_stack, dictionary, meta)
  end

  # there is an if clause on top or return_stack AND if_condition is FALSELY
  def process(["then" | tokens ], data_stack, [if_condition, %{if: _if_stack} | return_stack], dictionary, meta) when is_falsely(if_condition) do
    next(tokens, data_stack, return_stack, dictionary, meta)
  end

  # there is an if clause on top or return_stack AND if_condition is TRUTHLY
  def process(["then" | tokens ], data_stack, [if_condition, %{if: if_stack} | return_stack], dictionary, meta) when is_truthly(if_condition) do
    next(dump_stack_onto_stack(if_stack, tokens), data_stack, return_stack, dictionary, meta)
  end

  # IF/ELSE WORD ACCUMULATION

  # accumulate else words
  def process([if_else_token | tokens ], data_stack, [if_condition, %{if: if_stack, else: else_stack} | return_stack], dictionary, meta)  do
    next(tokens, data_stack, [if_condition, %{if: if_stack, else: [if_else_token | else_stack]} | return_stack], dictionary, meta)
  end

  # initialize else stack
  def process(["else" | tokens ], data_stack, [if_condition, %{if: if_stack} | return_stack], dictionary, meta)  do
    next(tokens, data_stack, [if_condition, %{if: if_stack, else: []} | return_stack], dictionary, meta)
  end

  # accumulate if words
  def process([if_token | tokens ], data_stack, [if_condition, %{if: if_stack} | return_stack], dictionary, meta)  do
    next(tokens, data_stack, [if_condition, %{if: [if_token | if_stack]} | return_stack], dictionary, meta)
  end

  # initialize if stack
  def process(["if" | tokens ], data_stack, [if_condition | return_stack], dictionary, meta)  do
    next(tokens, data_stack, [if_condition, %{if: []} | return_stack], dictionary, meta)
  end

  # #---------------------------------------------
  # # Flow control: start end DO do_stack LOOP
  # #---------------------------------------------

  # # DO/LOOP WORD ACCUMULATION

  # def process(["do" | tokens ], [count, end_count | data_stack], return_stack, dictionary, meta)  do
  #   next(tokens, data_stack, [count, end_count, %{do: tokens} | return_stack], dictionary, meta)
  # end

  # # copy the top of a LOOP's return stack to the data stack
  # def process(["i" | tokens ], data_stack, [count, _end_count, %{do: _do_tokens} | _] = return_stack, dictionary, meta)  do
  #   next(tokens, [count | data_stack], return_stack, dictionary, meta)
  # end

  # # copy the top of the return stack to the data stack
  # def process(["r@" | tokens ], data_stack, [count | _] = return_stack, dictionary, meta)  do
  #   next(tokens, [count | data_stack], return_stack, dictionary, meta)
  # end

  # # move the top of the data stack to the return stack
  # def process([">r" | tokens ], [data | data_stack], return_stack, dictionary, meta)  do
  #   next(tokens, data_stack, [data | return_stack], dictionary, meta)
  # end

  # # move the top of the return stack to the data stack
  # def process(["r>" | tokens ], data_stack, [data | return_stack], dictionary, meta)  do
  #   next(tokens, [data | data_stack], return_stack, dictionary, meta)
  # end

  # # copy data from return stack after LOOP's definition to the data stack
  # def process(["j" | tokens ], data_stack, [_count, _end_count, %{do: _do_tokens}, data | _] = return_stack, dictionary, meta)  do
  #   next(tokens, [data | data_stack], return_stack, dictionary, meta)
  # end

  # # loop: keep processing do_tokens till count < end_count, each step incrementing count by 1
  # def process(["loop" | tokens ], data_stack, [count, end_count, %{do: do_tokens} | return_stack], dictionary, meta)  do
  #   count = count + 1

  #   case count < end_count do
  #     true -> next(do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack], dictionary, meta)
  #     false -> next(tokens, data_stack, return_stack, dictionary, meta)
  #   end
  # end

  # # loop: keep processing do_tokens till count < end_count, incrementing count by top value on the data stack
  # def process(["+loop" | tokens ], [inc | data_stack], [count, end_count, %{do: do_tokens} | return_stack], dictionary, meta)  do
  #   count = count + inc

  #   case count < end_count do
  #     true -> next(do_tokens, data_stack, [count, end_count, %{do: do_tokens} | return_stack], dictionary, meta)
  #     false -> next(tokens, data_stack, return_stack, dictionary, meta)
  #   end
  # end

  #---------------------------------------------
  # Literal values
  #---------------------------------------------

  def process([value | tokens ], data_stack, return_stack, dictionary, meta) when not is_binary(value) do
    next(tokens, [value | data_stack], return_stack, dictionary, meta)

  end

  #---------------------------------------------
  # Dictionary handler
  #---------------------------------------------

  def process([word_name | tokens ], data_stack, return_stack, dictionary, meta) when is_binary(word_name) do
    # process word
    result = case get_dictionary_word(dictionary, word_name) do
      # function: execute function
      {:word, function, _} when is_function(function) -> function.(tokens, data_stack, return_stack, dictionary, meta)
      # tokens: add tokens at beginning of current tokens
      {:word, word_tokens, _} when is_list(word_tokens) -> {word_tokens ++ tokens, data_stack, return_stack, dictionary, meta}
      # variable: store the name on top of stack
      {:var, _} -> {tokens, [word_name | data_stack], return_stack, dictionary, meta}
      # constant: copy value on top of data stack
      {:const, value} -> {tokens, [value | data_stack], return_stack, dictionary, meta}
      # unknown: copy value on top of data stack
      {:unknown_word, value} -> {tokens, [value | data_stack], return_stack, dictionary, meta}
      # invalid: should never happen
      invalid -> raise "invalid word definition: #{inspect(invalid, limit: :infinity)}"
    end

    # handle responses
    case result do
      {tokens, data_stack, return_stack, dictionary, meta} -> next(tokens, data_stack, return_stack, dictionary, meta)
      result -> result
    end
  end


end
