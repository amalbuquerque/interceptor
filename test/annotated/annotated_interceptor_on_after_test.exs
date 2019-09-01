defmodule AnnotatedInterceptorOnAfterTest do
  use ExUnit.Case

  @process_name :annotated_after_test_process

  describe "module with a single function" do
    test "it intercepts the function after it is called" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter1.to_intercept()

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter1, :to_intercept, []}
    end
  end

  describe "module with two functions and other statement" do
    test "it intercepts the function after it is called" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter2.to_intercept()

      callback_calls = get_agent_messages()

      [{intercepted_timestamp, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert result < intercepted_timestamp
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter2, :to_intercept, []}
    end

    test "it also intercepts the other function" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter2.other_to_intercept()

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert result == "HELLO"
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter2, :other_to_intercept, []}
    end
  end

  describe "module with two functions and a private one" do
    test "it intercepts the function" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter3.other_to_intercept(4)

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, result_callback, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == result_callback
      assert result == 10
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter3, :other_to_intercept, [4]}
    end

    test "it doesn't intercept the function that isn't configured" do
      {:ok, _pid} = spawn_agent()

      now = Interceptor.Utils.timestamp()
      Process.sleep(50)
      result = AnnotatedInterceptedOnAfter3.not_to_intercept()

      callback_calls = get_agent_messages()

      assert result > now
      assert length(callback_calls) == 0
    end
  end

  describe "module with two definitions of the same function, the first has a guard clause" do
    test "it intercepts the guarded function" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter4.to_intercept_guarded(:should_return_atom)

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, result_callback, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == result_callback
      assert result == "ATOM should_return_atom"
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter4, :to_intercept_guarded, [:should_return_atom]}
    end

    test "it intercepts the function without guard" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter4.to_intercept_guarded("boomerang")

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, result_callback, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == result_callback
      assert result == "SOMETHING ELSE boomerang"
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter4, :to_intercept_guarded, ["boomerang"]}
    end
  end

  describe "module with two definitions of the same function, both match on integers" do
    test "it intercepts the first function definition" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter5.it_has_threes(3)

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, result_callback, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == result_callback
      assert result == "Has one three"
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter5, :it_has_threes, [3]}
    end

    test "it intercepts the second function definition" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter5.it_has_threes(33)

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, result_callback, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == result_callback
      assert result == "Has two threes"
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter5, :it_has_threes, [33]}
    end
  end

  describe "module with two definitions of the same function, the first one match on `abc`" do
    test "it intercepts the first function definition" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter5.its_abc("abc")

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, result_callback, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == result_callback
      assert result == true
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter5, :its_abc, ["abc"]}
    end

    test "it intercepts the second function definition" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedOnAfter5.its_abc(%{a: "map"})

      callback_calls = get_agent_messages()

      [{_intercepted_timestamp, result_callback, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == result_callback
      assert result == false
      assert intercepted_mfa == {AnnotatedInterceptedOnAfter5, :its_abc, [:arg_cant_be_intercepted]}
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
