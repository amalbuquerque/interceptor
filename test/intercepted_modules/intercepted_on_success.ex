defmodule OnSuccess.Callback do
  def on_success({_module, _function, _arity} = mfa, result, started_at) do
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
  end
end
