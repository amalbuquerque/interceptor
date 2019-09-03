defmodule AnnotatedAfter.OwnCallback do
  def right_after({_module, _function, _args} = mfa, result) do
    Agent.update(:annotated_after_test_process,
      fn messages ->
        [{:callback_overridden, result, mfa} | messages]
      end)
  end
end

defmodule AnnotatedMyOwn.InterceptConfig do
  def get_intercept_config do
    %{
      {AnnotatedInterceptedOnAfterOwnConfiguration1, :to_intercept, 0} => [
        after: {AnnotatedAfter.OwnCallback, :right_after, 2}
      ]
    }
  end
end

defmodule AnnotatedInterceptedOnAfterOwnConfiguration1 do
  use Interceptor.Annotated, config: AnnotatedMyOwn.InterceptConfig

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

defmodule AnnotatedInterceptedOnAfterOwnConfiguration2 do
  use Interceptor.Annotated, config: %{
      {AnnotatedInterceptedOnAfterOwnConfiguration2, :to_intercept, 0} => [
        after: {AnnotatedAfter.OwnCallback, :right_after, 2}
      ]
    }

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

defmodule AnnotatedInterceptedOnAfterOwnConfiguration3 do
  use Interceptor.Annotated, config: %{
      "AnnotatedInterceptedOnAfterOwnConfiguration3.to_intercept/0" => [
        after: "AnnotatedAfter.OwnCallback.right_after/2"
      ]
    }

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end

defmodule AnnotatedInterceptedOnAfterOwnConfiguration4 do
  use Interceptor.Annotated, config: %{
      "AnnotatedInterceptedOnAfterOwnConfiguration4.to_intercept/0" => [
        after: {AnnotatedAfter.OwnCallback, :right_after, 2}
      ]
    }

  @intercept true
  def to_intercept(), do: Interceptor.Utils.timestamp()
end
