defmodule ForthVM.Words.Messages do
  @moduledoc """
  Core messages words
  """

  @doc """
  send: (message_data cnt ":"word process_id -- ) ( -- ) sends a message to a process inside the current core. The message is handled by a word with same name minus the ":" prefix. Cnt is the number elements in the data stack to be included in the message.
  """
  def _send(
        tokens,
        [process_id, ":" <> word_name, cnt | data_stack],
        return_stack,
        dictionary,
        %{core_id: core_id, process_id: process_id} = meta
      ) do
    {message_data, data_stack} =
      case cnt do
        0 -> {[], data_stack}
        # FIXME: add error handling when cnt > data_stack
        cnt -> Enum.split(data_stack, cnt)
      end

    ForthVM.send_message(core_id, process_id, word_name, [cnt | message_data])

    ForthVM.Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end
end
