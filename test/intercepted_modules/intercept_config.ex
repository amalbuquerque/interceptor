defmodule InterceptConfig do
  @config %{
  # :debug => true,
  # on before tests
  {InterceptedOnBefore1, :to_intercept, 0} => [before: {Before.Callback, :before}],
  {InterceptedOnBefore2, :to_intercept, 0} => [before: {Before.Callback, :before}],
  {InterceptedOnBefore2, :other_to_intercept, 0} => [before: {Before.Callback, :before}],
  {InterceptedOnBefore3, :other_to_intercept, 1} => [before: {Before.Callback, :before}],
  {InterceptedOnBefore4, :to_intercept, 0} => [before: {Before.Callback, :before}],

  # on after tests
  {InterceptedOnAfter1, :to_intercept, 0} => [after: {After.Callback, :right_after}],
  {InterceptedOnAfter2, :to_intercept, 0} => [after: {After.Callback, :right_after}],
  {InterceptedOnAfter2, :other_to_intercept, 0} => [after: {After.Callback, :right_after}],
  {InterceptedOnAfter3, :other_to_intercept, 1} => [after: {After.Callback, :right_after}],

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
