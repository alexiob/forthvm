defmodule ForthVM.TokenizerTest do
  use ExUnit.Case

  alias ForthVM.Tokenizer

  test "interpreter should work" do
    source = """
    : hello-world
    # first comment
    "hello world" 42 4.2 print # this is an inline comment
    # second comment
    ;
    hello-world
    string true false
    """

    tokens = Tokenizer.parse(source, :inline)

    assert tokens == [
      {:string, {:inline, 0, 0}, ":"},
      {:string, {:inline, 0, 1}, "hello-world"},
      {:string, {:inline, 2, 0}, "hello world"},
      {:integer, {:inline, 2, 1}, 42},
      {:float, {:inline, 2, 2}, 4.2},
      {:string, {:inline, 2, 3}, "print"},
      {:string, {:inline, 4, 0}, ";"},
      {:string, {:inline, 5, 0}, "hello-world"},
      {:string, {:inline, 6, 0}, "string"},
      {:boolean, {:inline, 6, 1}, true},
      {:boolean, {:inline, 6, 2}, false},
      # {:command, {}, :halt}
    ]
  end
end
