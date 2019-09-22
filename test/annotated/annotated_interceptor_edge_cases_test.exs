defmodule AnnotatedInterceptorEdgeCasesTest do
  use ExUnit.Case

  @process_name :annotated_edge_cases_test_process

  describe "functions with argument using `<>`" do
    test "it passes the argument with the prefix before `<>`" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedEdgeCases1.intercept_with_prefix("some_prefix:blabla")

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {AnnotatedInterceptedEdgeCases1, :intercept_with_prefix, ["some_prefix:blabla"]}
    end
  end

  describe "module with functions with ignored arguments" do
    test "it passes the ignored arguments as `:arg_cant_be_intercepted`" do
      {:ok, _pid} = spawn_agent()

      result = AnnotatedInterceptedEdgeCases1.to_intercept(1, 2, 3)

      callback_calls = get_agent_messages()

      [{_started_at, _ended_at, callback_result, intercepted_mfa}] = callback_calls

      assert length(callback_calls) == 1
      assert result == callback_result
      assert intercepted_mfa == {AnnotatedInterceptedEdgeCases1, :to_intercept, [1, 2, :arg_cant_be_intercepted]}
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
