defmodule ForthVM do
  @moduledoc """
  Documentation for `ForthVM`.
  """

  def start(num_cores: num_cores) do
    children = [
      {ForthVM.Supervisor, num_cores: num_cores}
    ]

    opts = [strategy: :one_for_one, name: ForthVM]

    Supervisor.start_link(children, opts)
  end

  defdelegate core_pid(core_id), to: ForthVM.Supervisor
  defdelegate execute(core_id, process_id, source, dictionary \\ nil), to: ForthVM.Supervisor
  defdelegate load(core_id, process_id, source), to: ForthVM.Supervisor
  defdelegate spawn(core_id, process_id, dictionary \\ nil), to: ForthVM.Supervisor
  defdelegate send_message(core_id, process_id, word_name, message_data), to: ForthVM.Supervisor
end
