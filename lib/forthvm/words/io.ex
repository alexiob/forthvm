defmodule ForthVM.Words.IO do
  @moduledoc """
  IO words
  """

  alias ForthVM.Process

  # ---------------------------------------------
  # IO side effects
  # ---------------------------------------------

  @doc """
  set-io-device: ( name -- ) set the current IO device to the value on the top of the data_stack
  """
  def set_io_device(
        tokens,
        [device_name | data_stack],
        return_stack,
        dictionary,
        %{io: %{device: device, devices: devices}} = meta
      ) do
    device = Map.get(devices, device_name, device)

    Process.next(tokens, data_stack, return_stack, dictionary, %{
      meta
      | io: Map.put(meta.io, :device, device)
    })
  end

  @doc """
  emit: ( c -- ) pops and prints (without cr) the binary of an ascii value on the top of the data_stack
  """
  def emit(tokens, [c | data_stack], return_stack, dictionary, %{io: %{device: device}} = meta) do
    IO.write(device, <<c>>)

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  cr: ( -- ) emits a carriage return
  """
  def cr(tokens, data_stack, return_stack, dictionary, %{io: %{device: device}} = meta) do
    IO.puts(device, "")

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  .: ( x -- ) pops and prints the literal value on the top of the data_stack
  """
  def dot(tokens, [x | data_stack], return_stack, dictionary, %{io: %{device: device}} = meta) do
    IO.write(device, "#{x}")

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  puts: ( x -- ) pops and prints the literal value on the top of the data_stack
  """
  def puts(tokens, [x | data_stack], return_stack, dictionary, %{io: %{device: device}} = meta) do
    IO.puts(device, x)

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  inspect: ( x -- ) pops and prints the inspected value on the top of the data_stack
  """
  def inspect(tokens, [x | data_stack], return_stack, dictionary, %{io: %{device: device}} = meta) do
    IO.inspect(device, x, limit: :infinity)

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  .s: ( -- ) prints the whole data_stack, without touching it
  """
  def dump_data_stack(
        tokens,
        data_stack,
        return_stack,
        dictionary,
        %{io: %{device: device}} = meta
      ) do
    data_stack
    |> Enum.reverse()
    |> Enum.each(fn x -> IO.write(device, "#{x} ") end)

    Process.next(tokens, data_stack, return_stack, dictionary, meta)
  end

  @doc """
  "?": ( var -- ) fetch a variable value and prints it
  """
  def fetch_puts(tokens, data_stack, return_stack, dictionary, meta) do
    Process.next(["@", "." | tokens], data_stack, return_stack, dictionary, meta)
  end
end
