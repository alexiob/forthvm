defmodule ForthVM.Core.Utils do

  #---------------------------------------------
  # Custom guards
  #---------------------------------------------
  defguard is_falsely(value) when value == False or value == nil or value == 0 or value == ""
  defguard is_truthly(value) when not is_falsely(value)

  # #---------------------------------------------
  # # Truthy/Falsely utilities
  # #---------------------------------------------

  # def is_false(value) do
  #   value == False or value == nil or value == 0 or value == ""
  # end
  # def is_true(value) do
  #   not is_falsely(value)
  # end

  #---------------------------------------------
  # Stack utilities
  #---------------------------------------------

  def dump_stack_onto_stack([], stack) when is_list(stack) do
    stack
  end
  def dump_stack_onto_stack([h | t], stack) when is_list(stack) do
    dump_stack_onto_stack(t, [h | stack])
  end
end
