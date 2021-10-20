defmodule ForthVM.VM do
  alias ForthVM.Process

  defstruct name: "", id: 0, processes: []

  @default_reductions 1000

  def new(name, id, num_processes) do
    %__MODULE__{
      id: id,
      name: name,
      processes:
        for(
          process_id <- 0..(num_processes - 1),
          do: Process.new("process-#{id}", process_id)
        )
    }
  end

  def add_process(vm = %__MODULE__{processes: processes}, name, process_id) do
    %{vm | processes: [Process.new(name, process_id) | processes]}
  end

  def remove_process(vm = %__MODULE__{}, process = %Process{}) do
    remove_process_by_id(vm, process.id)
  end

  def remove_process_by_name(vm = %__MODULE__{processes: processes}, name) do
    %{vm | processes: Enum.reject(processes, fn process -> process.name == name end)}
  end

  def remove_process_by_id(vm = %__MODULE__{processes: processes}, process_id) do
    %{vm | processes: Enum.reject(processes, fn process -> process.id == process_id end)}
  end

  def run(vm, reductions \\ @default_reductions) do
    %{vm | processes: Enum.map(vm.processes, &run_process(&1, reductions))}
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
