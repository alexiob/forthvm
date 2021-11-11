defmodule ForthVM.Core do
  @moduledoc """
  Single core able to run multiple processes
  """
  alias ForthVM.Process

  defstruct id: nil, processes: [], io: nil

  @default_reductions 1_000
  @core_io_device_name "core_io"

  # ---------------------------------------------
  # Core
  # ---------------------------------------------

  def new(id \\ nil, io \\ :stdio) do
    %__MODULE__{
      id: id || System.unique_integer(),
      processes: [],
      io: io
    }
  end

  def core_id(id) when is_binary(id) do
    id
  end

  def core_id(id) do
    "core_#{id}"
  end

  def run(%__MODULE__{} = core, reductions \\ @default_reductions) do
    %{core | processes: Enum.map(core.processes, &run_process(&1, reductions))}
  end

  def load(%__MODULE__{io: io} = core, process_id, code)
      when is_binary(process_id) or is_number(process_id) do
    case find_process(core, process_id) do
      nil ->
        IO.puts(io, "Unknown process #{process_id}")
        core

      process ->
        load(core, process, code)
    end
  end

  def load(%__MODULE__{} = core, %Process{} = process, code) do
    process = load_process(process, code)
    replace_process(core, process.id, process)
  end

  def execute(%__MODULE__{io: io} = core, process_id, code)
      when is_binary(process_id) or is_number(process_id) do
    case find_process(core, process_id) do
      nil ->
        IO.puts(io, "Unknown process #{process_id}")
        core

      process ->
        execute(core, process, code)
    end
  end

  def execute(%__MODULE__{} = core, %Process{} = process, code, reductions \\ @default_reductions) do
    process = execute_process(process, code, reductions)
    replace_process(core, process.id, process)
  end

  def send_message(%__MODULE__{io: io} = core, process_id, word_name, message_data) do
    case find_process(core, process_id) do
      nil ->
        IO.puts(io, "Can not send message #{word_name} to unknown process #{process_id}")
        core

      %{context: {tokens, data_stack, return_stack, dictionary, meta}} = process ->
        meta = %{meta | messages: [{word_name, message_data} | meta.messages]}
        process = %{process | context: {tokens, data_stack, return_stack, dictionary, meta}}

        replace_process(core, process.id, process)
    end
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
        %__MODULE__{id: core_id, processes: processes, io: io} = core,
        process_id \\ nil,
        dictionary \\ nil
      ) do
    case find_process(core, process_id) do
      nil ->
        process =
          Process.new(core_id, process_id, dictionary)
          |> Process.add_io_device(@core_io_device_name, io)
          |> Process.set_io_device(@core_io_device_name)

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

  def execute_process(%Process{} = process, source, reductions) when is_binary(source) do
    execute_process(process, ForthVM.Tokenizer.parse(source), reductions)
  end

  def execute_process(%Process{context: context} = process, tokens, reductions)
      when is_list(tokens) do
    {status, context, exit_value} = Process.execute(context, tokens, reductions)
    %{process | context: context, status: status, exit_value: exit_value}
  end
end
