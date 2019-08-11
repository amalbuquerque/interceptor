defmodule After.OwnCallback do
  def right_after({_module, _function, _args} = mfa, result) do
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

defmodule InterceptedOnAfterOwnConfiguration2 do
  use Interceptor, config: %{
      {InterceptedOnAfterOwnConfiguration2, :to_intercept, 0} => [
        after: {After.OwnCallback, :right_after, 2}
      ]
    }

  Interceptor.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
  end
end

defmodule InterceptedOnAfterOwnConfiguration3 do
  use Interceptor, config: %{
      "InterceptedOnAfterOwnConfiguration3.to_intercept/0" => [
        after: "After.OwnCallback.right_after/2"
      ]
    }

  Interceptor.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
  end
end

defmodule InterceptedOnAfterOwnConfiguration4 do
  use Interceptor, config: %{
      "InterceptedOnAfterOwnConfiguration4.to_intercept/0" => [
        after: {After.OwnCallback, :right_after, 2}
      ]
    }

  Interceptor.intercept do
    def to_intercept(), do: Interceptor.Utils.timestamp()
  end
end
