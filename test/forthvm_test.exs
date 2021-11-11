defmodule ForthVMTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "greets the world" do
    assert capture_io(fn ->
             start_supervised({ForthVM.Supervisor, num_cores: 2})

             %ForthVM.Core{
               id: core_id,
               io: :stdio
             } = ForthVM.execute(1, nil, "42 puts")

             assert core_id == 1
           end) == "42\n\n"
  end
end
