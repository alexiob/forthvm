defmodule ForthVM.Words.Data do
  @moduledoc """
  Custom data words
  """

  alias ForthVM.Process

  @doc """
  l[: ( x y z -- l ) collect all tokens till ] is found and store on the data stack as a list
  """
  def list_start(tokens, data_stack, return_stack, dictionary, meta) do
    {list_tokens, tokens, _depth} = collect_list_tokens(tokens, "l[", "]", [], 1)

    Process.next(
      tokens,
      [list_tokens | data_stack],
      return_stack,
      dictionary,
      meta
    )
  end

  # start collecting tokens between start and end elements. handles recursive entries
  defp collect_list_tokens([token | tokens], start_token, end_token, collected_tokens, depth)
       when token == start_token do
    {list_tokens, tokens, depth} =
      collect_list_tokens(tokens, start_token, end_token, [], depth + 1)

    case depth == 0 do
      true ->
        {[list_tokens | collected_tokens], tokens, 0}

      false ->
        collect_list_tokens(
          tokens,
          start_token,
          end_token,
          [list_tokens | collected_tokens],
          depth
        )
    end
  end

  # stop collecting tokens
  defp collect_list_tokens([token | tokens], _start_token, end_token, collected_tokens, depth)
       when token == end_token do
    {Enum.reverse(collected_tokens), tokens, depth - 1}
  end

  # collecting tokens
  defp collect_list_tokens([token | tokens], start_token, end_token, collected_tokens, depth) do
    collect_list_tokens(tokens, start_token, end_token, [token | collected_tokens], depth)
  end
end
