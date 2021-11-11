defmodule ForthVM.TokenizerTest do
  @moduledoc false
  use ExUnit.Case

  alias ForthVM.Tokenizer

  test "split_line should handle strings correctly" do
    assert ["a", "b\n c\n", "d", "e\n"] == Tokenizer.split_line(~s[a "b\n c\n" d "e\n"])
    assert ["b\n c\n"] == Tokenizer.split_line(~s["b\n c\n"])

    assert ["*** Hello wonderful world! ***\n", "puts"] ==
             Tokenizer.split_line(~s["*** Hello wonderful world! ***\n" puts])
  end

  test "Tokenizer should work" do
    source = """
    : hello-world
    "hello world" 42 4.2 print
    ;

    hello-world
    string true false nil
    """

    tokens = Tokenizer.parse(source)

    assert tokens == [
             ":",
             "hello-world",
             "hello world",
             42,
             4.2,
             "print",
             ";",
             "hello-world",
             "string",
             true,
             false,
             nil
           ]
  end
end
