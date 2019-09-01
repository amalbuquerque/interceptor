defmodule AnnotatedWrapper.Callback do
  def wrap_returns_result({_module, _function, _args} = mfa, lambda) do
    result = lambda.()

    Agent.update(:annotated_wrapper_test_process,
      fn messages ->
        [{Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)

    result
  end

  def wrap_returns_hello({_module, _function, _args} = mfa, lambda) do
    result = lambda.()

    Agent.update(:annotated_wrapper_test_process,
      fn messages ->
        [{Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)

    "Hello"
  end
end

defmodule AnnotatedInterceptedByWrapper1 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

defmodule AnnotatedInterceptedByWrapper2 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()

  @intercept true
  def other_to_intercept(), do: "HELLO"

  IO.puts("This statement doesn't interfere in any way")
end

defmodule AnnotatedInterceptedByWrapper3 do
  use Interceptor.Annotated

  @intercept true
  def not_to_intercept(), do: Interceptor.Utils.timestamp()

  @intercept true
  def other_to_intercept(w), do: w + private_function(1, 2, 3)

  defp private_function(x, y, z), do: x+y+z
end

defmodule AnnotatedInterceptedByWrapper4 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

