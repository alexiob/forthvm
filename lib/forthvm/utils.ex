defmodule ForthVM.Utils do
  @moduledoc false

  # ---------------------------------------------
  # Custom guards
  # ---------------------------------------------
  defguard is_falsely(value) when value == false or value == nil or value == 0 or value == ""
  defguard is_truthly(value) when not is_falsely(value)

  # ---------------------------------------------
  # Error handling
  # ---------------------------------------------

  def error(message, context) do
    {:error, context, message}
  end

  # ---------------------------------------------
  # Stack utilities
  # ---------------------------------------------

  def dump_stack_onto_stack([], stack) when is_list(stack) do
    stack
  end

  def dump_stack_onto_stack([h | t], stack) when is_list(stack) do
    dump_stack_onto_stack(t, [h | stack])
  end
end
