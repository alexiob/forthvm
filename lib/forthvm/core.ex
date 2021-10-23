defmodule ForthVM.Core do
  @moduledoc """
  Single core able to run multiple processes
  """
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

  def run(%__MODULE__{} = core, reductions \\ @default_reductions) do
    %{core | processes: Enum.map(core.processes, &run_process(&1, reductions))}
  end

  def load(%__MODULE__{} = core, process_id, code)
      when is_binary(process_id) or is_number(process_id) do
    case find_process(core, process_id) do
      # FIXME: should error using VM IO
      nil ->
        IO.puts("Unknown process #{process_id}")
        core

      process ->
        load(core, process, code)
    end
  end

  def load(%__MODULE__{} = core, %Process{} = process, code) do
    process = load_process(process, code)
    replace_process(core, process.id, process)
  end

  # ---------------------------------------------
  # Processes
  # ---------------------------------------------

  def find_process(%__MODULE__{processes: processes}, process_id) do
    Enum.find(processes, fn process -> process.id == process_id end)
  end

  def replace_process(%__MODULE__{processes: processes} = core, process_id, new_process) do
    processes =
      Enum.map(processes, fn process ->
        if process.id == process_id do
          new_process
        else
          process
        end
      end)

    %{core | processes: processes}
  end

  def spawn_process(
        %__MODULE__{processes: processes} = core,
        process_id \\ nil,
        dictionary \\ nil
      ) do
    case find_process(core, process_id) do
      nil ->
        process = Process.new(process_id, dictionary)
        {%{core | processes: [process | processes]}, process}

      process ->
        {core, process}
    end
  end

  def kill_process(%__MODULE__{} = core, %Process{} = process) do
    kill_process(core, process.id)
  end

  def kill_process(%__MODULE__{processes: processes} = core, process_id) do
    %{core | processes: Enum.reject(processes, fn process -> process.id == process_id end)}
  end

  def run_process(%Process{context: context} = process, reductions) do
    {status, context, exit_value} = Process.run(context, reductions)
    %{process | context: context, status: status, exit_value: exit_value}
  end

  def load_process(%Process{} = process, source) when is_binary(source) do
    load_process(process, ForthVM.Tokenizer.parse(source))
  end

  def load_process(%Process{context: context} = process, tokens) when is_list(tokens) do
    %{process | context: Process.load(context, tokens)}
  end
end
