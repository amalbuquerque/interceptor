defmodule InterceptorWildcardedMfaTest do
  use ExUnit.Case

  @process_name :wildcarded_mfa_test_process

  describe "intercepted function MFA with arity wildcards" do
    test "it intercepts the same function with arity 1" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedWildcardedMfa1.foo(123)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedWildcardedMfa1, :foo, [123]}
    end

    test "it intercepts the same function with arity 2" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedWildcardedMfa1.foo(123, 456)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedWildcardedMfa1, :foo, [123, 456]}
    end

    test "it intercepts the same function with arity 5" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedWildcardedMfa1.foo(123, 456, 789, 333, 222)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedWildcardedMfa1, :foo, [123, 456, 789, 333, 222]}
    end

    test "it doesn't intercept a function without intercept configuration" do
      {:ok, _pid} = spawn_agent()

      InterceptedWildcardedMfa1.foo_nop("plz", "no intercept")

      assert [] == get_agent_messages()
    end
  end

  describe "intercepted function MFA with function and arity wildcards for a given module" do
    test "it intercepts the same function with arity 1" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedWildcardedMfa2.foo(123)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedWildcardedMfa2, :foo, [123]}
    end

    test "it intercepts the same function with arity 2" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedWildcardedMfa2.foo(123, 456)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedWildcardedMfa2, :foo, [123, 456]}
    end

    test "it intercepts the same function with arity 5" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedWildcardedMfa2.foo(123, 456, 789, 333, 222)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedWildcardedMfa2, :foo, [123, 456, 789, 333, 222]}
    end

    test "it intercepts other function" do
      {:ok, _pid} = spawn_agent()

      result = InterceptedWildcardedMfa2.xyz(123)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {InterceptedWildcardedMfa2, :xyz, [123]}
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
