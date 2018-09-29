defmodule InterceptConfig do
  @config %{
  # :debug => true,
  # on before tests
  {InterceptedOnBefore1, :to_intercept, 0} => [on_before: {Before.Callback, :on_before}],
  {InterceptedOnBefore2, :to_intercept, 0} => [on_before: {Before.Callback, :on_before}],
  {InterceptedOnBefore2, :other_to_intercept, 0} => [on_before: {Before.Callback, :on_before}],
  {InterceptedOnBefore3, :other_to_intercept, 1} => [on_before: {Before.Callback, :on_before}],

  # on after tests
  {InterceptedOnAfter1, :to_intercept, 0} => [on_after: {After.Callback, :on_after}],
  {InterceptedOnAfter2, :to_intercept, 0} => [on_after: {After.Callback, :on_after}],
  {InterceptedOnAfter2, :other_to_intercept, 0} => [on_after: {After.Callback, :on_after}],
  {InterceptedOnAfter3, :other_to_intercept, 1} => [on_after: {After.Callback, :on_after}],

  # on success tests
  {InterceptedOnSuccess1, :to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success}],
  {InterceptedOnSuccess2, :to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success}],
  {InterceptedOnSuccess2, :other_to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success}],
  {InterceptedOnSuccess3, :other_to_intercept, 1} => [on_success: {OnSuccess.Callback, :on_success}],

  # on error tests
  {InterceptedOnError1, :to_intercept, 0} => [on_error: {OnError.Callback, :on_error}],
  {InterceptedOnError2, :to_intercept, 0} => [on_error: {OnError.Callback, :on_error}],
  {InterceptedOnError2, :other_to_intercept, 0} => [on_error: {OnError.Callback, :on_error}],
  {InterceptedOnError3, :other_to_intercept, 1} => [on_error: {OnError.Callback, :on_error}],

  # wrapper tests
  {InterceptedByWrapper1, :to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_result}],
  {InterceptedByWrapper2, :to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_result}],
  {InterceptedByWrapper2, :other_to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_result}],
  {InterceptedByWrapper3, :other_to_intercept, 1} => [wrapper: {Wrapper.Callback, :wrap_returns_result}],
  {InterceptedByWrapper4, :to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_hello}],
}

  def get(), do: @config
end
