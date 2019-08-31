defmodule AnnotatedAfter.Callback do
  def right_after({_module, _function, _args} = mfa, result) do
    Agent.update(:annotated_after_test_process,
      fn messages ->
        [{Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
    "Doesn't influence the function at all"
  end
end

defmodule AnnotatedInterceptedOnAfter1 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

defmodule AnnotatedInterceptedOnAfter2 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()

  @intercept true
  def other_to_intercept(), do: "HELLO"

  IO.puts("This statement doesn't interfere in any way")
end

defmodule AnnotatedInterceptedOnAfter3 do
  use Interceptor.Annotated

  @intercept true
  def not_to_intercept(), do: Interceptor.Utils.timestamp()

  @intercept true
  def other_to_intercept(w), do: w + private_function(1, 2, 3)

  @intercept true
  defp private_function(x, y, z), do: x+y+z
end

defmodule AnnotatedInterceptedOnAfter4 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept_guarded(arg) when is_atom(arg), do: "ATOM #{arg}"

  @intercept true
  def to_intercept_guarded(arg), do: "SOMETHING ELSE #{arg}"
end

defmodule AnnotatedInterceptedOnAfter5 do
  use Interceptor.Annotated

  @intercept true
  def it_has_threes(3) do
    "Has one three"
  end

  @intercept true
  def it_has_threes(33), do: "Has two threes"

  @intercept true
  def its_abc("abc"), do: true

  @intercept true
  def its_abc(_else), do: false

  @intercept true
  def something(%{abc: xyz}) do
    "something #{xyz}"
  end
end
