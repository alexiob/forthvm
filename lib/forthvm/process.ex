defmodule ForthVM.Process do
  @moduledoc """
  A Forth processing instance
  """
  import ForthVM.Utils

  defstruct id: nil, context: {}, status: nil, exit_value: nil

  # ---------------------------------------------
  # Custom guards
  # ---------------------------------------------

  def new(id \\ nil, dictionary \\ nil) do
    %__MODULE__{
      id: id || System.unique_integer(),
      context: {[], [], [], dictionary || ForthVM.Dictionary.new(), new_meta()},
      status: nil,
      exit_value: nil
    }
  end

  def new_meta() do
    %{
      reductions: 0,
      sleep: 0,
      debug: false,
      io: %{
        device: :stdio,
        devices: %{
          "stdio" => :stdio
        }
      }
    }
  end

  # ---------------------------------------------
  # Entry points
  # ---------------------------------------------

  # run program described by tokens, using the provided dictionary, for, at max, number of reductions
  def run(tokens, %{} = dictionary, reductions) do
    process(tokens, [], [], dictionary, %{new_meta() | reductions: reductions})
  end

  # run program defined in the provided context, for, at max, number of reductions
  def run({tokens, data_stack, return_stack, dictionary, meta}, reductions) do
    process(tokens, data_stack, return_stack, dictionary, %{meta | reductions: reductions})
  end

  # run program defined in the provided context plus the new tokens passed to the function, for, at max, number of reductions
  def execute({tokens, data_stack, return_stack, dictionary, meta}, new_tokens, reductions)
      when is_list(new_tokens) do
    process(tokens ++ new_tokens, data_stack, return_stack, dictionary, %{
      meta
      | reductions: reductions
    })
  end

  # load a program into the process
  def load({_tokens, _data_stack, _return_stack, dictionary, meta}, tokens) do
    {tokens, [], [], dictionary, %{meta | sleep: 0, reductions: 0}}
  end

  # ---------------------------------------------
  # Handle next processing step
  # ---------------------------------------------

  @doc """
  Mainly used handle reduction-driven processing
  """
  def next(tokens, data_stack, return_stack, dictionary, meta)

  # process is sleeping
  def next(tokens, data_stack, return_stack, dictionary, %{sleep: till} = meta) when till != 0 do
    if System.monotonic_time() < till do
      {:yield, {tokens, data_stack, return_stack, dictionary, meta}, nil}
    else
      process(tokens, data_stack, return_stack, dictionary, %{meta | sleep: 0})
    end
  end

  # process consumed all available reductions
  def next(tokens, data_stack, return_stack, dictionary, %{reductions: 0} = meta) do
    {:yield, {tokens, data_stack, return_stack, dictionary, meta}, nil}
  end

  def next(tokens, data_stack, return_stack, dictionary, %{reductions: reductions} = meta) do
    process(tokens, data_stack, return_stack, dictionary, %{meta | reductions: reductions - 1})
  end

  # ---------------------------------------------
  # Handle exit
  # ---------------------------------------------

  def exit(tokens, data_stack, return_stack, dictionary, meta, exit_value) do
    {:exit, {tokens, data_stack, return_stack, dictionary, meta}, exit_value}
  end

  # ---------------------------------------------
  # Process instructions
  # ---------------------------------------------

  @doc """
  Process a core word.
  """
  def process(tokens, data_stack, return_stack, dictionary, meta)

  # ---------------------------------------------
  # Process exit conditions
  # ---------------------------------------------

  # no more tokens, one last value in the data stack
  def process([], [last_value] = data_stack, return_stack, dictionary, meta) do
    exit([], data_stack, return_stack, dictionary, meta, last_value)
  end

  # no more tokens or data
  def process([], [], return_stack, dictionary, meta) do
    exit([], [], return_stack, dictionary, meta, nil)
  end

  # no more tokens but data in the stack
  def process([], data_stack, return_stack, dictionary, meta) do
    exit([], data_stack, return_stack, dictionary, meta, data_stack)
  end

  # ---------------------------------------------
  # Flow control: if_condition IF if_stack [ELSE else_stack] THEN
  # ---------------------------------------------

  # NEEDS TO BE IMPLEMENTED HERE AS IT HAS UNNAMED WORDS

  # there is an if/else clause on top or return_stack AND if_condition is FALSELY
  def process(
        ["then" | tokens],
        data_stack,
        [if_condition, %{if: _if_stack, else: else_stack} | return_stack],
        dictionary,
        meta
      )
      when is_falsely(if_condition) do
    next(dump_stack_onto_stack(else_stack, tokens), data_stack, return_stack, dictionary, meta)
  end

  # there is an if/else clause on top or return_stack AND if_condition is TRUTHLY
  def process(
        ["then" | tokens],
        data_stack,
        [if_condition, %{if: if_stack, else: _else_stack} | return_stack],
        dictionary,
        meta
      )
      when is_truthly(if_condition) do
    next(dump_stack_onto_stack(if_stack, tokens), data_stack, return_stack, dictionary, meta)
  end

  # there is an if clause on top or return_stack AND if_condition is FALSELY
  def process(
        ["then" | tokens],
        data_stack,
        [if_condition, %{if: _if_stack} | return_stack],
        dictionary,
        meta
      )
      when is_falsely(if_condition) do
    next(tokens, data_stack, return_stack, dictionary, meta)
  end

  # there is an if clause on top or return_stack AND if_condition is TRUTHLY
  def process(
        ["then" | tokens],
        data_stack,
        [if_condition, %{if: if_stack} | return_stack],
        dictionary,
        meta
      )
      when is_truthly(if_condition) do
    next(dump_stack_onto_stack(if_stack, tokens), data_stack, return_stack, dictionary, meta)
  end

  # IF/ELSE WORD ACCUMULATION

  # accumulate else words
  def process(
        [if_else_token | tokens],
        data_stack,
        [if_condition, %{if: if_stack, else: else_stack} | return_stack],
        dictionary,
        meta
      ) do
    next(
      tokens,
      data_stack,
      [if_condition, %{if: if_stack, else: [if_else_token | else_stack]} | return_stack],
      dictionary,
      meta
    )
  end

  # initialize else stack
  def process(
        ["else" | tokens],
        data_stack,
        [if_condition, %{if: if_stack} | return_stack],
        dictionary,
        meta
      ) do
    next(
      tokens,
      data_stack,
      [if_condition, %{if: if_stack, else: []} | return_stack],
      dictionary,
      meta
    )
  end

  # accumulate if words
  def process(
        [if_token | tokens],
        data_stack,
        [if_condition, %{if: if_stack} | return_stack],
        dictionary,
        meta
      ) do
    next(
      tokens,
      data_stack,
      [if_condition, %{if: [if_token | if_stack]} | return_stack],
      dictionary,
      meta
    )
  end

  # initialize if stack
  def process(["if" | tokens], [if_condition | data_stack], return_stack, dictionary, meta) do
    next(tokens, data_stack, [if_condition, %{if: []} | return_stack], dictionary, meta)
  end

  # ---------------------------------------------
  # Literal values
  # ---------------------------------------------

  def process([value | tokens], data_stack, return_stack, dictionary, meta)
      when not is_binary(value) do
    next(tokens, [value | data_stack], return_stack, dictionary, meta)
  end

  # ---------------------------------------------
  # Dictionary handler
  # ---------------------------------------------

  def process([word_name | tokens], data_stack, return_stack, dictionary, meta)
      when is_binary(word_name) do
    # process word
    result =
      process_word(
        ForthVM.Dictionary.get(dictionary, word_name),
        word_name,
        tokens,
        data_stack,
        return_stack,
        dictionary,
        meta
      )

    # handle responses
    case result do
      {tokens, data_stack, return_stack, dictionary, meta} ->
        next(tokens, data_stack, return_stack, dictionary, meta)

      result ->
        result
    end
  end

  def process_word(
        {:word, function, word_meta},
        word_name,
        tokens,
        data_stack,
        return_stack,
        dictionary,
        %{io: %{device: device}} = meta
      )
      when is_function(function) do
    try do
      function.(tokens, data_stack, return_stack, dictionary, meta)
    rescue
      _e in FunctionClauseError ->
        message = "processing word '#{word_name}' #{word_meta.doc}"
        error(message, {tokens, data_stack, return_stack, dictionary, meta}, device)

      e in Protocol.UndefinedError ->
        message = "undefined protocol '#{inspect(e.protocol)}' for value '#{inspect(e.value)}"
        error(message, {tokens, data_stack, return_stack, dictionary, meta}, device)

      e ->
        error(e.message, {tokens, data_stack, return_stack, dictionary, meta}, device)
    end
  end

  def process_word(
        {:word, word_tokens, _},
        _word_name,
        tokens,
        data_stack,
        return_stack,
        dictionary,
        meta
      )
      when is_list(word_tokens) do
    # tokens: add tokens at beginning of current tokens
    {word_tokens ++ tokens, data_stack, return_stack, dictionary, meta}
  end

  def process_word({:var, _}, word_name, tokens, data_stack, return_stack, dictionary, meta) do
    # variable: store the name on top of stack
    {tokens, [word_name | data_stack], return_stack, dictionary, meta}
  end

  def process_word(
        {:const, value},
        _word_name,
        tokens,
        data_stack,
        return_stack,
        dictionary,
        meta
      ) do
    # constant: copy value on top of data stack
    {tokens, [value | data_stack], return_stack, dictionary, meta}
  end

  def process_word(
        {:unknown_word, value},
        _word_name,
        tokens,
        data_stack,
        return_stack,
        dictionary,
        meta
      ) do
    # unknown: copy value on top of data stack
    {tokens, [value | data_stack], return_stack, dictionary, meta}
  end

  def process_word(
        {:error, context, message},
        _word_name,
        _tokens,
        _data_stack,
        _return_stack,
        _dictionary,
        %{io: %{device: device}} = _meta
      ) do
    # error: print message and exit
    error(message, context, device)
  end

  def process_word(
        invalid,
        _word_name,
        tokens,
        data_stack,
        return_stack,
        dictionary,
        %{io: %{device: device}} = meta
      ) do
    # invalid: should never happen
    error(
      "invalid word definition: #{inspect(invalid, limit: :infinity)}",
      {tokens, data_stack, return_stack, dictionary, meta},
      device
    )
  end

  # ---------------------------------------------
  # IO
  # ---------------------------------------------

  def add_io_device(
        %__MODULE__{context: {tokens, data_stack, return_stack, dictionary, meta}} = process,
        device_name,
        device
      ) do
    devices = Map.put(meta.io.devices, device_name, device)

    meta = %{
      meta
      | io: Map.put(meta.io, :devices, devices)
    }

    %{process | context: {tokens, data_stack, return_stack, dictionary, meta}}
  end

  def set_io_device(
        %__MODULE__{context: {tokens, data_stack, return_stack, dictionary, meta}} = process,
        device_name
      ) do
    device = Map.get(meta.io.devices, device_name, meta.io.device)

    meta = %{
      meta
      | io: Map.put(meta.io, :device, device)
    }

    %{process | context: {tokens, data_stack, return_stack, dictionary, meta}}
  end

  def get_io_device(
        %__MODULE__{context: {_tokens, _data_stack, _return_stack, _dictionary, meta}},
        device_name
      ) do
    Map.get(meta.io.devices, device_name, meta.io.device)
  end

  def get_active_io_device(%__MODULE__{
        context: {_tokens, _data_stack, _return_stack, _dictionary, meta}
      }) do
    meta.io.device
  end
end
