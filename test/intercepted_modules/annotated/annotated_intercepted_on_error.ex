defmodule AnnotatedOnError.Callback do
  def on_error({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:annotated_on_error_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
    "Doesn't influence the function at all"
  end
end

defmodule AnnotatedInterceptedOnError1 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: 1/0
end

defmodule AnnotatedInterceptedOnError2 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Process.sleep(200) && 2/0

  @intercept true
  def other_to_intercept(), do: 3/0

  IO.puts("This statement doesn't interfere in any way")
end

defmodule AnnotatedInterceptedOnError3 do
  use Interceptor.Annotated

  def definitely_not_to_intercept(), do: length("No macros plz")

  @intercept true
  def not_to_intercept(), do: length("Not intercepted")

  @intercept true
  def other_to_intercept(w), do: (w + private_function(1, 2, 3))/0

  @intercept true
  defp private_function(x, y, z), do: x+y+z
end
