defmodule InterceptorPrivateOwnConfigurationOnSuccessErrorTest do
  use ExUnit.Case

  describe "module with two functions, own streamlined configuration" do
    test "it intercepts the private function after it is successfully called" do
      agent_name = :private_on_success_test_process
      {:ok, _pid} = spawn_agent(agent_name)

      result = InterceptedPrivateOnSuccessOnErrorOwnConfiguration.public_square_plus_10(3)

      callback_calls = get_agent_messages(agent_name)

      [{
        started_at_timestamp,
        intercepted_timestamp,
        intercepted_result,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert result == intercepted_result
      time_it_took_microseconds = intercepted_timestamp - started_at_timestamp
      assert time_it_took_microseconds > 500_000

      assert intercepted_mfa == {InterceptedPrivateOnSuccessOnErrorOwnConfiguration, :square_plus_10, 1}
    end

    test "it intercepts the private function after it raises an error" do
      agent_name = :private_on_error_test_process
      {:ok, _pid} = spawn_agent(agent_name)

      assert_raise ArithmeticError, ~r/bad argument in arithmetic expression/, fn ->
        InterceptedPrivateOnSuccessOnErrorOwnConfiguration.public_divide_by_0(42)
      end

      callback_calls = get_agent_messages(agent_name)

      [{
        started_at_timestamp,
        intercepted_timestamp,
        intercepted_error,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert %ArithmeticError{} == intercepted_error
      time_it_took_microseconds = intercepted_timestamp - started_at_timestamp
      assert time_it_took_microseconds > 600_000

      assert intercepted_mfa == {InterceptedPrivateOnSuccessOnErrorOwnConfiguration, :divide_by_0, 1}
    end
  end

  defp spawn_agent(process_name) do
    process_name
    |> Process.whereis()
    |> kill_agent()

    {:ok, pid} = Agent.start_link(fn -> [] end)
    true = Process.register(pid, process_name)

    {:ok, pid}
  end

  defp kill_agent(nil), do: false
  defp kill_agent(pid) do
    case Process.alive?(pid) do
      true -> Process.exit(pid, :kill)
      _ -> false
    end
  end

  defp get_agent_messages(process_name), do: Agent.get(process_name, &(&1))
end
