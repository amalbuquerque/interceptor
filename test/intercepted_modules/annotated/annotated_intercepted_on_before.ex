defmodule AnnotatedBefore.Callback do
  def before({_module, _function, _args} = mfa) do
    Agent.update(:annotated_before_test_process,
      fn messages ->
        [{Interceptor.Utils.timestamp(), mfa} | messages]
      end)
    "Doesn't influence the function at all"
  end
end

defmodule AnnotatedInterceptedOnBefore1 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

defmodule AnnotatedInterceptedOnBefore2 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()

  @intercept true
  def other_to_intercept(), do: "HELLO"

  IO.puts("This statement doesn't interfere in any way")
end

defmodule AnnotatedInterceptedOnBefore3 do
  use Interceptor.Annotated

  @intercept true
  def not_to_intercept(), do: Interceptor.Utils.timestamp()

  @intercept true
  def other_to_intercept(w), do: w + private_function(1, 2, 3)

  @intercept true
  defp private_function(x, y, z), do: x+y+z
end

defmodule AnnotatedInterceptedOnBefore4 do
  use Interceptor.Annotated

  # TODO: Solve known issue 1
  @intercept true
  def to_intercept(), do: "Hello, even without args"

  @intercept true
  def bla, do: 123
end
