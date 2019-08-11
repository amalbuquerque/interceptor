defmodule OnSuccess.Callback do
  def on_success({_module, _function, _args} = mfa, result, started_at) do
    Agent.update(:on_success_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
    "Doesn't influence the function at all"
  end
end

defmodule InterceptedOnSuccess1 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
  end
end

defmodule InterceptedOnSuccess2 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(), do: Process.sleep(200)
    def other_to_intercept(), do: "HELLO"

    IO.puts("This statement doesn't interfere in any way")
  end
end

defmodule InterceptedOnSuccess3 do
  require Interceptor, as: I

  def definitely_not_to_intercept(), do: "No macros plz"

  I.intercept do
    def not_to_intercept(), do: "Not intercepted"
    def other_to_intercept(w), do: w + private_function(1, 2, 3)

    defp private_function(x, y, z), do: x+y+z

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
end

defmodule La.Lu.Li.Weird.MyStruct do
  defstruct name: "ryuichi sakamoto", age: 67
end


defmodule InterceptedOnSuccess4 do
  require Interceptor, as: I

  alias La.Lu.Li.Weird.MyStruct

  I.intercept do
    def with_struct(%MyStruct{name: n, age: a}) do
      [n, a]
    end

    def with_structs(
      %MyStruct{name: n1, age: a1},
      %La.Lu.Li.Weird.MyStruct{name: n2, age: a2}) do
      [n1, a1, n2, a2]
    end

    def with_struct_already_assigned(%MyStruct{name: _n, age: _a} = xpto) do
      [xpto.name, xpto.age]
    end
  end
end
