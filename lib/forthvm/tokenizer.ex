defmodule ForthVM.Tokenizer do
  @doc """
  Parse a text source
  """
  def parse(source) when is_binary(source) do
    source
    |> String.split("\n")
    |> parse()
  end

  # Parse a list of text sources
  def parse(source) when is_list(source) do
    source
    |> Enum.map(&parse_line(&1))
    |> List.flatten()
    |> convert_labels_to_absolute()
  end

  @doc """
  Parse a single line, possibly containing multiple words
  """
  def parse_line(source) when is_binary(source) do
    source
    |> split_line()
    |> tokenize_list()
  end

  # Handle words with core types: boolean, float, integer, nil
  def parse_line(source)
      when is_boolean(source) or is_float(source) or is_integer(source) or is_nil(source) do
    source
  end

  @doc """
  Split line by space delimited words, respecting double quoted strings
  """
  def split_line(line) do
    Regex.split(~r{\s+|"(?:\\"|[^"])+"}, String.trim(line), include_captures: true)
    |> Enum.map(fn s -> s |> String.trim() |> String.trim("\"") end)
    |> Enum.filter(fn s -> s != "" end)
  end

  @doc """
  Tokenizes a list of words, returning a list of tokens
  """
  def tokenize_list(source) when is_list(source) do
    source
    |> Enum.reduce_while([], fn input, acc -> tokenize_word(input, acc) end)
    |> Enum.reverse()
  end

  def tokenize_word(input, acc) do
    case tokenize_word(input) do
      token -> {:cont, [token | acc]}
    end
  end

  # handle core types represented as strings
  def tokenize_word("true") do
    true
  end

  def tokenize_word("false") do
    false
  end

  def tokenize_word("nil") do
    nil
  end

  # handle numbers and normal text
  def tokenize_word(source) when is_binary(source) do
    case tokenize_word_to_number(source) do
      {:ok, token} -> token
      {:next} -> source
    end
  end

  # VERY INEFFICIENT
  # try to convert text to a number: first to float, than to integer, than just returns text.
  def tokenize_word_to_number(source) when is_binary(source) do
    case tokenize_word_to_float(source) do
      {:ok, _} = result -> result
      {:next} -> tokenize_word_to_integer(source)
    end
  end

  # try to conver text to float
  def tokenize_word_to_float(source) when is_binary(source) do
    try do
      {:ok, String.to_float(source)}
    rescue
      _ -> {:next}
    end
  end

  # try to conver text to integer
  def tokenize_word_to_integer(source) when is_binary(source) do
    try do
      {:ok, String.to_integer(source)}
    rescue
      _ -> {:next}
    end
  end

  @doc """
  Convert labels to absolute values
  """
  def convert_labels_to_absolute(tokens) do
    acc = %{idx: 0, tokens: [], labels: %{}}

    %{tokens: tokens, labels: labels} = Enum.reduce(tokens, acc, &collect_labels(&1, &2))

    tokens
    |> List.flatten()
    |> Enum.reverse()
    |> convert_labels(labels)
  end

  def collect_labels(token, acc) do
    case token do
      "::" <> name when is_binary(name) and name != "" ->
        %{acc | labels: Map.put_new(acc.labels, name, acc.idx)}

      token ->
        %{acc | tokens: [token | acc.tokens], idx: acc.idx + 1}
    end
  end

  def convert_labels(tokens, labels) do
    tokens
    |> Enum.with_index()
    |> Enum.map(fn {token, idx} ->
      case token do
        ":" <> name when is_binary(name) and name != "" ->
          label_to_idx(Map.get(labels, name), idx)

        token ->
          token
      end
    end)
  end

  def label_to_idx(label_idx, idx) do
    # IO.puts(">>>CALC label_idx=#{label_idx} - idx=#{idx}")
    label_idx - (idx + 1)
  end
end
