defmodule ForthVM.Tokenizer do
  @comment "#"
  # @halt_token {:command, {}, :halt}

  def parse(source, source_id) when is_binary(source) do
    source
    |> String.split("\n")
    |> parse(source_id)
  end

  def parse(source, source_id) when is_list(source) do
    # IO.inspect(source, label: ">>> PARSE.LIST(#{source_id})")
    source
    |> Enum.with_index()
    |> Enum.map(fn {line_source, idx} -> parse_line(line_source, idx, source_id) end)
    |> List.flatten()
    # |> Enum.concat([@halt_token])
  end

  def parse_line(source, line_idx, source_id) when is_binary(source) do
    # IO.inspect(source, label: ">>> PARSE_LINE(#{source_id}:#{line_idx})")
    source
    |> split_line
    |> Enum.with_index()
    |> parse_list(line_idx, source_id)
  end

  def parse_line({_type, _mata, _code} = source, _line_idx, _source_id) do
    source
  end

  def parse_line(source, line_idx, source_id) when is_boolean(source) do
    {:boolean, {source_id, line_idx, 0}, source}
  end

  def parse_line(source, line_idx, source_id) when is_float(source) do
    {:float, {source_id, line_idx, 0}, source}
  end

  def parse_line(source, line_idx, source_id) when is_integer(source) do
    {:integer, {source_id, line_idx, 0}, source}
  end

  def split_line(line) do
    Regex.split(~r{\s+|"(?:\\"|[^"])+"}, String.trim((line)), include_captures: true)
    |> Enum.map(fn s -> s |> String.trim() |> String.trim("\"") end )
    |> Enum.filter(fn s -> s != "" end)
  end

  def parse_list(source, line_idx \\ nil, source_id \\ nil) when is_list(source) do
    source
    |> Enum.reduce_while([], fn input, acc -> tokenize_word(input, line_idx, source_id, acc) end)
    |> Enum.reverse()
  end

  def tokenize_word(input, line_idx, source_id, acc) do
    case tokenize_word(input, line_idx, source_id) do
      {:skip} -> {:halt, acc}
      token -> {:cont, [token | acc]}
    end
  end

  # handle comments, ignoring them
  def tokenize_word({@comment, _word_idx}, _source_id, _line_idx) do
    {:skip}
  end

  # handle booleans
  def tokenize_word({"true", word_idx}, line_idx, source_id) do
    {:boolean, {source_id, line_idx, word_idx}, true}
  end

  def tokenize_word({"false", word_idx}, line_idx, source_id) do
    {:boolean, {source_id, line_idx, word_idx}, false}
  end

  # handle numbers and normal text
  def tokenize_word({source, word_idx} = input, line_idx, source_id) when is_binary(source) do
    case tokenize_word_to_number(input, line_idx, source_id) do
      {:ok, token} -> token
      {:next} -> {:string, {source_id, line_idx, word_idx}, source}
    end
  end

  # VERY INEFFICIENT
  # try to convert text to a number: first to float, than to integer, than just returns text.
  def tokenize_word_to_number({source, _word_idx} = input, line_idx, source_id) when is_binary(source) do
    case tokenize_word_to_float(input, line_idx, source_id) do
      {:ok, _} = result -> result
      {:next} -> tokenize_word_to_integer(input, line_idx, source_id)
    end
  end

  # try to conver text to float
  def tokenize_word_to_float({source, word_idx}, line_idx, source_id) when is_binary(source) do
    try do
      {:ok, {:float, {source_id, line_idx, word_idx}, String.to_float(source)}}
    rescue
      _ -> {:next}
    end
  end

  # try to conver text to integer
  def tokenize_word_to_integer({source, word_idx}, line_idx, source_id) when is_binary(source) do
    try do
      {:ok, {:integer, {source_id, line_idx, word_idx}, String.to_integer(source)}}
    rescue
      _ -> {:next}
    end
  end
end
