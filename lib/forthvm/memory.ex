defmodule ForthVM.Memory do
  defstruct data: A.Vector, labels: %{}, max_size: 0

  alias ForthVM.Memory

  def new(max_size), do: %Memory{
    data: A.Vector.new([]),
    labels: %{},
    max_size: max_size
  }

  def size(memory = %Memory{}) do
    A.Vector.size(memory.data)
  end

  def add(memory = %Memory{}, value, label \\ nil) do
    pos = A.Vector.size(memory.data)

    case memory.max_size == pos do
      true -> {:error, :out_of_memory, "out of memory (#{A.Vector.size(memory.data)})"}
      false ->
        labels = case label do
          nil -> memory.labels
          _ -> Map.put(memory.labels, label, pos)
        end

        memory = %{ memory | data: A.Vector.append(memory.data, value), labels: labels }

        {memory, pos, label}
    end
  end

  def add!(memory = %Memory{}, value, label \\ nil) do
    case add(memory, value, label) do
      {:error, _error_type, message} -> raise message
      memory -> memory
    end
  end

  def get(memory = %Memory{}, pos) when is_integer(pos) do
    case pos >= 0 and pos <= A.Vector.size(memory.data) do
      true -> get!(memory, pos)
      false -> {:error, :out_of_memory, "position (#{pos}) is out of memory (#{A.Vector.size(memory.data)})"}
    end
  end

  def get(memory = %Memory{}, label) do
    case get_label(memory, label) do
      {:error, _, _} = error -> error
      pos -> get!(memory, pos)
    end
  end

  def get!(memory = %Memory{}, pos) when is_integer(pos) do
    A.Vector.fetch!(memory.data, pos)
  end

  def set(memory = %Memory{}, pos, value) when is_integer(pos) do
    case pos >= 0 and pos <= A.Vector.size(memory.data) do
      true -> %{memory | data: set!(memory, pos, value)}
      false -> {:error, :out_of_memory, "position (#{pos}) is out of memory (#{A.Vector.size(memory.data)})"}
    end
  end

  def set(memory = %Memory{}, label, value) do
    case get_label(memory, label) do
      {:error, _, _} = error -> error
      pos -> %{memory | data: set!(memory, pos, value)}
    end
  end

  def set!(memory = %Memory{}, pos, value) when is_integer(pos) do
    A.Vector.replace_at!(memory.data, pos, value)
  end

  def set_label(memory = %Memory{}, label, pos) do
    case pos >= 0 and pos <= A.Vector.size(memory.data) do
      true -> %{ memory | labels: Map.put(memory.labels, label, pos)}
      false -> {:error, :out_of_memory, "label '#{label}' position (#{pos}) is out of memory (#{A.Vector.size(memory.data)})"}
    end
  end

  def get_label(memory = %Memory{}, label) do
    case Map.get(memory.labels, label) do
      :nil -> {:error, :unknown_label, "unknown label '#{label}'"}
      pos -> pos
    end
  end
end
