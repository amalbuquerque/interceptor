defmodule OnError.Callback do
  def on_error({_module, _function, _arity} = mfa, result, started_at) do
    Agent.update(:on_error_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
    "Doesn't influence the function at all"
  end
end

defmodule InterceptedOnError1 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(), do: 1/0
  end
end

defmodule InterceptedOnError2 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(), do: Process.sleep(200) && 2/0
    def other_to_intercept(), do: 3/0

    IO.puts("This statement doesn't interfere in any way")
  end
end

defmodule InterceptedOnError3 do
  require Interceptor, as: I

  def definitely_not_to_intercept(), do: length("No macros plz")

  I.intercept do
    def not_to_intercept(), do: length("Not intercepted")
    def other_to_intercept(w), do: (w + private_function(1, 2, 3))/0

    defp private_function(x, y, z), do: x+y+z
  end
end
