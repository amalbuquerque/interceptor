defmodule AnnotatedOnSuccess.Callback do
  def on_success({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:annotated_on_success_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
    "Doesn't influence the function at all"
  end
end

defmodule AnnotatedInterceptedOnSuccess1 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

defmodule AnnotatedInterceptedOnSuccess2 do
  use Interceptor.Annotated

  @intercept true
  def to_intercept(), do: Process.sleep(200)

  @intercept true
  def other_to_intercept(), do: "HELLO"

  IO.puts("This statement doesn't interfere in any way")
end

defmodule AnnotatedInterceptedOnSuccess3 do
  use Interceptor.Annotated

  def definitely_not_to_intercept(), do: "No macros plz"

  @intercept true
  def not_to_intercept(), do: "Not intercepted"

  @intercept true
  def other_to_intercept(w), do: w + private_function(1, 2, 3)

  @intercept true
  defp private_function(x, y, z), do: x+y+z

  @intercept true
  def trickier_args_function(first_arg, [one, two, three], {abc, xyz}, %{baz: woz}, <<g,h,i>>, foo \\ "bar") do
    [
      first_arg,
      one,
      two,
      three,
      abc,
      xyz,
      woz,
      g,
      h,
      i,
      foo
    ]
  end
end

defmodule AnnotatedInterceptedOnSuccess4 do
  use Interceptor.Annotated

  alias La.Lu.Li.Weird.MyStruct

  @intercept true
  def with_struct(%MyStruct{name: n, age: a}) do
    [n, a]
  end

  @intercept true
  def with_structs(
    %MyStruct{name: n1, age: a1},
    %La.Lu.Li.Weird.MyStruct{name: n2, age: a2}) do
    [n1, a1, n2, a2]
  end

  @intercept true
  def with_struct_already_assigned(%MyStruct{name: _n, age: _a} = xpto) do
    [xpto.name, xpto.age]
  end
end
