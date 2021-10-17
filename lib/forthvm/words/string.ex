defmodule ForthVM.Words.String do
  alias ForthVM.Core

  # ---------------------------------------------
  # String manipulation
  # ---------------------------------------------

  @doc """
  .": ( -- s ) convert all next tokens to a single string, till " is found
  """
  def string_start(tokens, data_stack, return_stack, dictionary, meta) do
    {text, [_closed_quote | tokens]} = Enum.split_while(tokens, fn s -> s != "\"" end)

    Core.next(tokens, [Enum.join(text, " ") | data_stack], return_stack, dictionary, meta)
  end
end
