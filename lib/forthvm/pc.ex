defmodule ForthVM.PC do
  defstruct word: nil, idx: 0

  def new(word) do
    %__MODULE__{
      word: word,
      idx: 0
    }
  end

  def next(nil) do
    {nil, nil}
  end

  def next(pc = %__MODULE__{}) do
    word = get(pc)
    {inc(pc), word}
  end

  def get(%__MODULE__{word: {function, _meta} = word}) when is_function(function) do
    word
  end

  def get(%__MODULE__{word: {word, %{type: :def}}, idx: idx}) do
    A.Vector.fetch!(word, idx)
  end

  def get(%__MODULE__{word: words, idx: idx}) do
    A.Vector.fetch!(words, idx)
  end

  def inc(pc = %__MODULE__{idx: idx}, x \\ 1) do
    %{pc | idx: idx + x}
  end

  def set(nil, _) do
    nil
  end

  def set(pc = %__MODULE__{}, idx) when is_integer(idx) do
    %{pc | idx: idx}
  end

end
