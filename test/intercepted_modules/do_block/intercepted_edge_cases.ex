defmodule EdgeCases.Callbacks do
  def success_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:edge_cases_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end

  def error_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:edge_cases_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end
end

defmodule InterceptedEdgeCases1 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(a, b, _to_ignore), do: "#{a} #{b}"

    def intercept_with_prefix("some_prefix:" <> suffix), do: suffix
  end
end
