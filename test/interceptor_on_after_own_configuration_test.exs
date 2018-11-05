defmodule InterceptorOnAfterOwnConfigurationTest do
  use ExUnit.Case

  @process_name :after_test_process

  describe "module with a single function" do
    test "it intercepts the function after it is called" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnAfterOwnConfiguration1.to_intercept()

      callback_calls = get_agent_messages()

      [{:callback_overridden, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedOnAfterOwnConfiguration1, :to_intercept, 0}
    end
  end

  defp spawn_agent() do
    @process_name
    |> Process.whereis()
    |> kill_agent()

    {:ok, pid} = Agent.start_link(fn -> [] end)
    true = Process.register(pid, @process_name)

    {:ok, pid}
  end

  defp kill_agent(nil), do: false
  defp kill_agent(pid) do
    case Process.alive?(pid) do
      true -> Process.exit(pid, :kill)
      _ -> false
    end
  end

  defp get_agent_messages(), do: Agent.get(@process_name, &(&1))
end
