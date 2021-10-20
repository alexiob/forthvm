defmodule ForthVM.VM do
  alias ForthVM.Core

  defstruct name: "", id: 0, cores: []

  @default_reductions 1000

  def new(name, id, num_cores) do
    %__MODULE__{
      id: id,
      name: name,
      cores:
        for(
          core_id <- 0..(num_cores - 1),
          do: ForthVM.Core.new("core-#{id}", core_id)
        )
    }
  end

  def add_core(vm = %__MODULE__{cores: cores}, name, core_id) do
    %{vm | cores: [ForthVM.Core.new(name, core_id) | cores]}
  end

  def remove_core(vm = %__MODULE__{}, core = %Core{}) do
    remove_core_by_id(vm, core.id)
  end

  def remove_core_by_name(vm = %__MODULE__{cores: cores}, name) do
    %{vm | cores: Enum.reject(cores, fn core -> core.name == name end)}
  end

  def remove_core_by_id(vm = %__MODULE__{cores: cores}, core_id) do
    %{vm | cores: Enum.reject(cores, fn core -> core.id == core_id end)}
  end

  def run(vm, reductions \\ @default_reductions) do
    %{vm | cores: Enum.map(vm.cores, &run_core(&1, reductions))}
  end

  def run_core(core = %Core{context: context}, reductions) do
    %{core | context: Core.run(context, reductions)}
  end

  def load_core(core, source) when is_binary(source) do
    load_core(core, ForthVM.Tokenizer.parse(source))
  end

  def load_core(core = %Core{context: context}, tokens) when is_list(tokens) do
    %{core | context: Core.load(context, tokens)}
  end
end
