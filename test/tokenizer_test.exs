defmodule ForthVM.TokenizerTest do
  use ExUnit.Case

  alias ForthVM.Tokenizer

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
