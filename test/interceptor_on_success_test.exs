defmodule InterceptorOnSuccessTest do
  use ExUnit.Case

  @process_name :on_success_test_process

  describe "module with a single function" do
    test "it intercepts the function after it is successfully called" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnSuccess1.to_intercept()

      callback_calls = get_agent_messages()

      [{
        _started_at_timestamp,
        _intercepted_timestamp,
        intercepted_result,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert result == intercepted_result

      assert intercepted_mfa == {InterceptedOnSuccess1, :to_intercept, []}
    end
  end

  describe "module with two functions and other statement" do
    test "it intercepts the function on success" do
      {:ok, _pid} = spawn_agent()

      before_timestamp = Interceptor.Utils.timestamp()
      Process.sleep(10)

      result = InterceptedOnSuccess2.to_intercept()

      callback_calls = get_agent_messages()

      [{
        started_at_timestamp,
        intercepted_timestamp,
        intercepted_result,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert before_timestamp < started_at_timestamp
      time_it_took_microseconds = intercepted_timestamp - started_at_timestamp
      assert 200_000 < time_it_took_microseconds
      assert result == intercepted_result
      assert intercepted_mfa == {InterceptedOnSuccess2, :to_intercept, []}
    end

    test "it also intercepts the other function" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnSuccess2.other_to_intercept()

      callback_calls = get_agent_messages()

      [{
        _started_at_timestamp,
        _intercepted_timestamp,
        _intercepted_result,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert result == "HELLO"
      assert intercepted_mfa == {InterceptedOnSuccess2, :other_to_intercept, []}
    end
  end

  describe "module with two functions and a private one" do
    test "it intercepts the function on success" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnSuccess3.other_to_intercept(4)

      callback_calls = get_agent_messages()

      [{
        _started_at_timestamp,
        _intercepted_timestamp,
        _intercepted_result,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert result == 10
      assert intercepted_mfa == {InterceptedOnSuccess3, :other_to_intercept, [4]}
    end

    test "it doesn't intercept the function that isn't configured" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedOnSuccess3.not_to_intercept()

      callback_calls = get_agent_messages()

      assert result == "Not intercepted"
      assert length(callback_calls) == 0
    end

    test "it doesn't intercept the function that is outside of the intercept block" do
      {:ok, _pid} = spawn_agent()

      _result = InterceptedOnSuccess3.definitely_not_to_intercept()

      callback_calls = get_agent_messages()

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
