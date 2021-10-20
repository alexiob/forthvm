defmodule ForthVM.Words.Flow do
  import ForthVM.Utils

  alias ForthVM.Process

  # ---------------------------------------------
  # Flow control: start end DO do_stack LOOP
  # ---------------------------------------------

  @doc """
  do: ( end_count count -- ) start loop declaration
  """
  def _do(tokens, [count, end_count | data_stack], return_stack, dictionary, meta) do
    Process.next(
      tokens,
      data_stack,
      [count, end_count, %{do: tokens} | return_stack],
      dictionary,
      meta
    )
  end

  @doc """
  i: ( -- count ) copy the top of a LOOP's return stack to the data stack
  """
  def i(
        tokens,
        data_stack,
        [count, _end_count, %{do: _do_tokens} | _] = return_stack,
        dictionary,
        meta
      ) do
    Process.next(tokens, [count | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  r@: ( -- data )copy the top of the return stack to the data stack
  """
  def copy_r_to_d(tokens, data_stack, [data | _] = return_stack, dictionary, meta) do
    Process.next(tokens, [data | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  >r: ( data -- ) move the top of the data stack to the return stack
  """
  def move_d_to_r(tokens, [data | data_stack], return_stack, dictionary, meta) do
    Process.next(tokens, data_stack, [data | return_stack], dictionary, meta)
  end

  @doc """
  r>: ( -- data ) move the top of the return stack to the data stack
  """
  def move_r_to_d(tokens, data_stack, [data | return_stack], dictionary, meta) do
    Process.next(tokens, [data | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  j: ( -- data ) copy data from return stack after LOOP's definition to the data stack
  """
  def copy_r_loop_to_d(
        tokens,
        data_stack,
        [_count, _end_count, %{do: _do_tokens}, data | _] = return_stack,
        dictionary,
        meta
      ) do
    Process.next(tokens, [data | data_stack], return_stack, dictionary, meta)
  end

  @doc """
  loop: ( -- ) keep processing do_tokens till count < end_count, each step incrementing count by 1
  """
  def loop(
        tokens,
        data_stack,
        [count, end_count, %{do: do_tokens} | return_stack],
        dictionary,
        meta
      ) do
    count = count + 1

    case count < end_count do
      true ->
        Process.next(
          do_tokens,
          data_stack,
          [count, end_count, %{do: do_tokens} | return_stack],
          dictionary,
          meta
        )

      false ->
        Process.next(tokens, data_stack, return_stack, dictionary, meta)
    end
  end

  @doc """
  +loop: ( inc -- ) keep processing do_tokens till count < end_count, incrementing count by top value on the data stack
  """
  def plus_loop(
        tokens,
        [inc | data_stack],
        [count, end_count, %{do: do_tokens} | return_stack],
        dictionary,
        meta
      ) do
    count = count + inc

    case count < end_count do
      true ->
        Process.next(
          do_tokens,
          data_stack,
          [count, end_count, %{do: do_tokens} | return_stack],
          dictionary,
          meta
        )

      false ->
        Process.next(tokens, data_stack, return_stack, dictionary, meta)
    end
  end

  # ---------------------------------------------
  # Flow control: BEGIN until_stack UNTIL
  # ---------------------------------------------

  @doc """
  begin: ( -- ) start loop declaration
  """
  def begin(tokens, data_stack, return_stack, dictionary, meta) do
    Process.next(tokens, data_stack, [%{begin: tokens} | return_stack], dictionary, meta)
  end

  @doc """
  until: (bool -- ) keep processing untill contition is truthly
  """
  def until(
        tokens,
        [condition | data_stack],
        [%{begin: until_tokens} | return_stack],
        dictionary,
        meta
      ) do
    case is_falsely(condition) do
      true ->
        Process.next(
          until_tokens,
          data_stack,
          [%{begin: until_tokens} | return_stack],
          dictionary,
          meta
        )

      false ->
        Process.next(tokens, data_stack, return_stack, dictionary, meta)
    end
  end
end
