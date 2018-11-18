defmodule OwnCallbacks do
  def on_success({_module, _function, _arity} = mfa, result, started_at) do
    Agent.update(:private_on_success_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), result, mfa} | messages]
      end)
    "Yo, I don't influence anything"
  end

  def on_error({_module, _function, _arity} = mfa, error, started_at) do
    Agent.update(:private_on_error_test_process,
      fn messages ->
        [{started_at, Interceptor.Utils.timestamp(), error, mfa} | messages]
      end)
    "Yo, me neither"
  end
end

defmodule InterceptedPrivateOnSuccessOnErrorOwnConfiguration do
  use Interceptor, config: %{
    "InterceptedPrivateOnSuccessOnErrorOwnConfiguration.square_plus_10/1" =>
    [
      on_success: "OwnCallbacks.on_success/3",
      on_error: "OwnCallbacks.on_error/3"
    ],
    "InterceptedPrivateOnSuccessOnErrorOwnConfiguration.divide_by_0/1" =>
    [
      on_success: "OwnCallbacks.on_success/3",
      on_error: "OwnCallbacks.on_error/3"
    ]
  }

  Interceptor.intercept do
    def public_square_plus_10(x), do: square_plus_10(x)

    defp square_plus_10(x) do
      Process.sleep(500)
      x*x + 10
    end

    def public_divide_by_0(y), do: divide_by_0(y)

    defp divide_by_0(y) do
      Process.sleep(600)
      y/0
    end
  end
end
