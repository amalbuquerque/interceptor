defmodule AnnotatedEdgeCases.Callbacks do
  def success_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:annotated_edge_cases_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end

  def error_cb({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:annotated_edge_cases_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
  end
end

defmodule AnnotatedInterceptedEdgeCases1 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(a, b, _to_ignore), do: "#{a} #{b}"

  @intercept true
  def intercept_with_prefix("some_prefix:" <> abc), do: abc
end

defmodule AnnotatedInterceptedEdgeCases2 do
  use Interceptor.Annotated, attribute_name: :xpto_intercept

  @xpto_intercept true
  def to_intercept(a, b, _to_ignore), do: "#{a} #{b}"

  @xpto_intercept true
  def intercept_with_prefix("some_prefix:" <> abc), do: abc
end
