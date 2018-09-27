use Mix.Config

config :interceptor, configuration: %{
  # on before tests
  {InterceptedOnBefore1, :to_intercept, 0} => [on_before: {Before.Callback, :on_before, 1}],
  {InterceptedOnBefore2, :to_intercept, 0} => [on_before: {Before.Callback, :on_before, 1}],
  {InterceptedOnBefore2, :other_to_intercept, 0} => [on_before: {Before.Callback, :on_before, 1}],
  {InterceptedOnBefore3, :other_to_intercept, 1} => [on_before: {Before.Callback, :on_before, 1}],

  # on after tests
  {InterceptedOnAfter1, :to_intercept, 0} => [on_after: {After.Callback, :on_after, 2}],
  {InterceptedOnAfter2, :to_intercept, 0} => [on_after: {After.Callback, :on_after, 2}],
  {InterceptedOnAfter2, :other_to_intercept, 0} => [on_after: {After.Callback, :on_after, 1}],
  {InterceptedOnAfter3, :other_to_intercept, 1} => [on_after: {After.Callback, :on_after, 1}],
}
