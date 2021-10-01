defmodule ForthVM.Token do
  def is_token?({_type, _meta, _value}), do: true
  def is_token?(_), do: false
  defguard is_value(value) when is_binary(value) or is_boolean(value) or is_number(value) or is_nil(value)

  def type({type, _meta, _value}) do
    type
  end

  def meta({_type, meta, _value}) do
    meta
  end

  def value({_type, _meta, value}) do
    value
  end

  def value(value) when is_value(value) do
    value
  end
end
