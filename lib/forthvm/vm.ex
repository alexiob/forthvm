defmodule ForthVM.VM do
  alias ForthVM.Process

  defstruct id: nil, processes: []

  @default_reductions 1000

  # ---------------------------------------------
  # VM
  # ---------------------------------------------

  def new(id \\ nil) do
    %__MODULE__{
      id: id || System.unique_integer(),
      processes: []
    }
  end

  def run(vm, reductions \\ @default_reductions) do
    %{vm | processes: Enum.map(vm.processes, &run_process(&1, reductions))}
  end

  def load(vm, process_id, code) do
    case find_process(vm, process_id) do
      # FIXME: should error using VM IO
      nil ->
        IO.puts("Unknown process #{process_id}")
        {vm, process_id, nil}

      process ->
        process = load_process(process, code)
        replace_process(vm, process.id, process)
    end
  end

  # ---------------------------------------------
  # Processes
  # ---------------------------------------------

  def find_process(%__MODULE__{processes: processes}, process_id) do
    Enum.find(processes, fn process -> process.id == process_id end)
  end

  def replace_process(vm = %__MODULE__{processes: processes}, process_id, new_process) do
    processes =
      Enum.map(processes, fn process ->
        cond do
          process.id == process_id -> new_process
          true -> process
        end
      end)

    %{vm | processes: processes}
  end

  def spawn_process(vm = %__MODULE__{processes: processes}, process_id \\ nil) do
    case find_process(vm, process_id) do
      {vm, process_id, nil} ->
        process = Process.new(process_id)
        {%{vm | processes: [process | processes]}, process_id, process}

      process ->
        {vm, process.id, process}
    end
  end

  def kill_process(vm = %__MODULE__{}, process = %Process{}) do
    kill_process(vm, process.id)
  end

  def kill_process(vm = %__MODULE__{processes: processes}, process_id) do
    %{vm | processes: Enum.reject(processes, fn process -> process.id == process_id end)}
  end

  def run_process(process = %Process{context: context}, reductions) do
    %{process | context: Process.run(context, reductions)}
  end

  def load_process(process, source) when is_binary(source) do
    load_process(process, ForthVM.Tokenizer.parse(source))
  end

  def load_process(process = %Process{context: context}, tokens) when is_list(tokens) do
    %{process | context: Process.load(context, tokens)}
  end
end
