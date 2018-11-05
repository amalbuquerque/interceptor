defmodule After.OwnCallback do
  def right_after({_module, _function, _arity} = mfa, result) do
    Agent.update(:after_test_process,
      fn messages ->
        [{:callback_overridden, result, mfa} | messages]
      end)
  end
end

defmodule MyOwn.InterceptConfig do
  def get_intercept_config do
    %{
      {InterceptedOnAfterOwnConfiguration1, :to_intercept, 0} => [
        after: {After.OwnCallback, :right_after, 2}
      ]
    }
  end
end

defmodule InterceptedOnAfterOwnConfiguration1 do
  use Interceptor, config: MyOwn.InterceptConfig

  Interceptor.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
  end
end

# defmodule InterceptedOnAfter2 do
#   require Interceptor, as: I

#   I.intercept do
#     def to_intercept(), do: Interceptor.Utils.timestamp()
#     def other_to_intercept(), do: "HELLO"

#     IO.puts("This statement doesn't interfere in any way")
#   end
# end

# defmodule InterceptedOnAfter3 do
#   require Interceptor, as: I

#   I.intercept do
#     def not_to_intercept(), do: Interceptor.Utils.timestamp()
#     def other_to_intercept(w), do: w + private_function(1, 2, 3)

#     defp private_function(x, y, z), do: x+y+z
#   end
# end
