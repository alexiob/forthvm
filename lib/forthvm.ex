defmodule ForthVM do
  @moduledoc """
  A toy Forth-like virtual machine.

  I have written it to experiment implementing a stack-based preemtive multitasking
  interpreter (and to play) with Elixir.
  """

  @doc """
  Starts a new VM supervisor, initializin `num_cores` cores.

  ## Examples

  ForthVM.start(num_cores: 2)
  {:ok, #PID<0.375.0>}

  """
  def start(num_cores: num_cores) do
    children = [
      {ForthVM.Supervisor, num_cores: num_cores}
    ]

    opts = [strategy: :one_for_one, name: ForthVM]

    Supervisor.start_link(children, opts)
  end

  @doc """
  Returns a map with cores' id as keys and cores' pid as values.

  ## Examples

  ForthVM.Supervisor.cores()
  %{"core_1" => #PID<0.407.0>, "core_2" => #PID<0.408.0>}
  """
  defdelegate cores(), to: ForthVM.Supervisor

  @doc """
  Returns the PID for the Core with the given `core_id` string.

  ## Examples

  ForthVM.core_pid("core_2")
  #PID<0.408.0>
  """
  defdelegate core_pid(core_id), to: ForthVM.Supervisor

  @doc """
  Executes Forth code in `source` string using `process_id` Process
  managed by the `core_id` Core.
  Optionally, a custom Forth `dictionary` can be passed.

  Returns the updated Core state.

  ## Examples

  ForthVM.execute("core_2", "p_1", "40 2 +")
  %ForthVM.Core{
    id: 2,
    io: :stdio,
    processes: [
      %ForthVM.Process{
        context: {[], '*', [],
        %{
          "dup" => {:word, &ForthVM.Words.Stack.dup/5,
            %{doc: "duplicate element from top of stack", stack: "( x -- x x )"}},
          ...
        },
        %{
          core_id: 2,
          debug: false,
          io: %{
            device: :stdio,
            devices: %{"core_io" => :stdio, "stdio" => :stdio}
          },
          messages: [],
          process_id: "p_1",
          reductions: 997,
          sleep: 0
        }},
        core_id: nil,
        exit_value: 42,
        id: "p_1",
        status: :exit
      }
    ]
  }
  """
  defdelegate execute(core_id, process_id, source, dictionary \\ nil), to: ForthVM.Supervisor

  @doc """
  Loads Forth code from the `source` string into `process_id` Process
  managed by `core_id` Core, replacing all code currrently stored into the process.
  The loaded code is executed right away.

  If the `process_id` does not exist, a message will be logged, but no error raised.

  Returns the updated Core state.
  """
  defdelegate load(core_id, process_id, source), to: ForthVM.Supervisor

  @doc """
  Spawns a new process with given `process_id` that will be managed by the `core_id` Core,
  If `process_id` is `nil`, an new id will be automatically generated using `System.unique_integer()`.

  Returns the newly spawned Process' state.

  ## Examples

  ForthVM.spawn("core_2", "p_new")
  %ForthVM.Process{
    context: {[], [], [],
    %{
      "<<" => {:word, &ForthVM.Words.Logic.b_shift_left/5,
        %{doc: "bitwise shift left", stack: "( x y -- v )"}},
      ...
    },
    %{
      core_id: 2,
      debug: false,
      io: %{device: :stdio, devices: %{"core_io" => :stdio, "stdio" => :stdio}},
      messages: [],
      process_id: "p_new",
      reductions: 0,
      sleep: 0
    }},
    core_id: nil,
    exit_value: nil,
    id: "p_new",
    status: nil
  }
  """
  defdelegate spawn(core_id, process_id, dictionary \\ nil), to: ForthVM.Supervisor

  @doc """
  Sends a message to `process_id` Process managed by `core_id` Core:
  `word_name` is the name of the dictionary's word that will handle the message,
  `message_data` is a list containing the data to be placed on top of the data stack.

  The message will place `{word_name, message_data}` into the Process' messages FIFO queue.

  Messages are handled when the Process has no more tokens to process:
  - `word_name` is placed into the list of tokens to execute
  - `message_data` list is joined with the data stack
  - the message is removed from the `messages` queue

  This is a cast call, so nothing is returned.

  ## Examples

  ForthVM.send_message("core_2", "p_new", ".", ["hello world"])
  :ok
  hello world
  """
  defdelegate send_message(core_id, process_id, word_name, message_data), to: ForthVM.Supervisor
end
