defmodule ForthVM.ProcessWordMessageTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureIO

  @test_command "two one 42 :puts 1 send"
  @test_message {"puts", [42, "one", "two"]}

  test "message should be received by target process" do
    assert capture_io(fn ->
             start_supervised({ForthVM.Supervisor, num_cores: 2})

             core_pid = ForthVM.core_pid(1)

             :erlang.trace(core_pid, true, [:receive])

             ForthVM.execute(1, 1, @test_command)

             # wait for the send message to be received
             assert_received(
               {:trace, ^core_pid, :receive, {:"$gen_cast", {:send_message, 1, @test_message}}}
             )

             %{processes: [process | _]} = :sys.get_state(core_pid)

             {_tokens, _data_stack, _return_stack, _dictionary, %{messages: messages} = _meta} =
               process.context

             assert [@test_message] == messages

             # we wait for some output to be generated by the IO handler
             assert_receive({:trace, ^core_pid, :receive, {:io_reply, _, :ok}})
           end) == "42\n\n"
  end
end
