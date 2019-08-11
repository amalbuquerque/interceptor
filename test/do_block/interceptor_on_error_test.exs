defmodule InterceptorOnErrorTest do
  use ExUnit.Case

  @process_name :on_error_test_process

  describe "module with a single function" do
    test "it intercepts the function after it errors" do
      {:ok, _pid} = spawn_agent()

      assert_raise ArithmeticError, ~r/bad argument in arithmetic expression/, fn ->
        InterceptedOnError1.to_intercept()
      end

      callback_calls = get_agent_messages()

      [{
        _started_at_timestamp,
        _intercepted_timestamp,
        intercepted_error,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert %ArithmeticError{} == intercepted_error
      assert intercepted_mfa == {InterceptedOnError1, :to_intercept, []}
    end
  end

  describe "module with two functions and other statement" do
    test "it intercepts the function on error" do
      {:ok, _pid} = spawn_agent()

      before_timestamp = Interceptor.Utils.timestamp()
      Process.sleep(10)

      assert_raise ArithmeticError, ~r/bad argument in arithmetic expression/, fn ->
        InterceptedOnError2.to_intercept()
      end

      callback_calls = get_agent_messages()

      [{
        started_at_timestamp,
        intercepted_timestamp,
        intercepted_error,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert before_timestamp < started_at_timestamp
      time_it_took_microseconds = intercepted_timestamp - started_at_timestamp
      assert 200_000 < time_it_took_microseconds
      assert %ArithmeticError{} == intercepted_error
      assert intercepted_mfa == {InterceptedOnError2, :to_intercept, []}
    end

    test "it also intercepts the other function" do
      {:ok, _pid} = spawn_agent()

      assert_raise ArithmeticError, ~r/bad argument in arithmetic expression/, fn ->
        InterceptedOnError2.other_to_intercept()
      end

      callback_calls = get_agent_messages()

      [{
        _started_at_timestamp,
        _intercepted_timestamp,
        _intercepted_error,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert intercepted_mfa == {InterceptedOnError2, :other_to_intercept, []}
    end
  end

  describe "module with two functions and a private one" do
    test "it intercepts the function on error" do
      {:ok, _pid} = spawn_agent()

      assert_raise ArithmeticError, ~r/bad argument in arithmetic expression/, fn ->
        InterceptedOnError3.other_to_intercept(4)
      end

      callback_calls = get_agent_messages()

      [{
        _started_at_timestamp,
        _intercepted_timestamp,
        _intercepted_error,
        intercepted_mfa
      }] = callback_calls

      assert length(callback_calls) == 1
      assert intercepted_mfa == {InterceptedOnError3, :other_to_intercept, [4]}
    end

    test "it doesn't intercept the function that isn't configured" do
      {:ok, _pid} = spawn_agent()

      assert_raise ArgumentError, ~r/argument error/, fn ->
        InterceptedOnError3.not_to_intercept()
      end

      callback_calls = get_agent_messages()

      assert length(callback_calls) == 0
    end

    test "it doesn't intercept the function that is outside of the intercept block" do
      {:ok, _pid} = spawn_agent()

      assert_raise ArgumentError, ~r/argument error/, fn ->
        InterceptedOnError3.definitely_not_to_intercept()
      end

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
