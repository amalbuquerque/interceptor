use Mix.Config

config :interceptor, configuration: %{
  {InterceptedOnBefore1, :to_intercept, 0} => [on_before: {Callback, :on_before, 1}],
  {InterceptedOnBefore2, :to_intercept, 0} => [on_before: {Callback, :on_before, 1}],
  {InterceptedOnBefore2, :other_to_intercept, 0} => [on_before: {Callback, :on_before, 1}],
  {InterceptedOnBefore3, :other_to_intercept, 1} => [on_before: {Callback, :on_before, 1}]
}
