defmodule Wrapper.Callback do
  def wrap_returns_result({module, function, arity} = mfa, lambda) do
    result = lambda.()

    Agent.update(:wrapper_test_process,
      fn messages ->
        [{Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)

    result
  end

  def wrap_returns_hello({module, function, arity} = mfa, lambda) do
    result = lambda.()

    Agent.update(:wrapper_test_process,
      fn messages ->
        [{Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)

    "Hello"
  end
end

defmodule InterceptedByWrapper1 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
  end
end

defmodule InterceptedByWrapper2 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
    def other_to_intercept(), do: "HELLO"

    IO.puts("This statement doesn't interfere in any way")
  end
end

defmodule InterceptedByWrapper3 do
  require Interceptor, as: I

  I.intercept do
    def not_to_intercept(), do: Interceptor.Utils.timestamp()
    def other_to_intercept(w), do: w + private_function(1, 2, 3)

    defp private_function(x, y, z), do: x+y+z
  end
end

defmodule InterceptedByWrapper4 do
  require Interceptor, as: I

  I.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
  end
end

