defmodule InterceptorOnBeforeTest do
  use ExUnit.Case

  @process_name :before_test_process

  describe "module with a single function" do
    test "it intercepts the function before it is called" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnBefore1.to_intercept()

      callback_calls = get_agent_messages()

      [{intercepted_timestamp, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result > intercepted_timestamp
      assert intercepted_mfa == {InterceptedOnBefore1, :to_intercept, 0}
    end
  end

  describe "module with two functions and other statement" do
    test "it intercepts the function before it is called" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnBefore2.to_intercept()

      callback_calls = get_agent_messages()

      [{intercepted_timestamp, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result > intercepted_timestamp
      assert intercepted_mfa == {InterceptedOnBefore2, :to_intercept, 0}
    end

    test "it also intercepts the other function" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnBefore2.other_to_intercept()

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == "HELLO"
      assert intercepted_mfa == {InterceptedOnBefore2, :other_to_intercept, 0}
    end
  end

  describe "module with two functions and a private one" do
    test "it intercepts the function" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnBefore3.other_to_intercept(4)

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == 10
      assert intercepted_mfa == {InterceptedOnBefore3, :other_to_intercept, 1}
    end

    test "it doesn't intercept the function that isn't configured" do
      {:ok, _pid} = spawn_agent()

      now = Interceptor.Utils.timestamp()
      Process.sleep(50)
      result = InterceptedOnBefore3.not_to_intercept()

      callback_calls = get_agent_messages()

      assert result > now
      assert length(callback_calls) == 0
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
