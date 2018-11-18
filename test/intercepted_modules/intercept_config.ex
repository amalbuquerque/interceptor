defmodule InterceptConfig do
  @config %{
  # on before tests
  {InterceptedOnBefore1, :to_intercept, 0} => [before: {Before.Callback, :before, 1}],
  {InterceptedOnBefore2, :to_intercept, 0} => [before: {Before.Callback, :before, 1}],
  {InterceptedOnBefore2, :other_to_intercept, 0} => [before: {Before.Callback, :before, 1}],
  {InterceptedOnBefore3, :other_to_intercept, 1} => [before: {Before.Callback, :before, 1}],
  {InterceptedOnBefore4, :to_intercept, 0} => [before: {Before.Callback, :before, 1}],

  # on after tests
  {InterceptedOnAfter1, :to_intercept, 0} => [after: {After.Callback, :right_after, 2}],
  {InterceptedOnAfter2, :to_intercept, 0} => [after: {After.Callback, :right_after, 2}],
  {InterceptedOnAfter2, :other_to_intercept, 0} => [after: {After.Callback, :right_after, 2}],
  {InterceptedOnAfter3, :other_to_intercept, 1} => [after: {After.Callback, :right_after, 2}],

  # on success tests
  {InterceptedOnSuccess1, :to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success, 3}],
  {InterceptedOnSuccess2, :to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success, 3}],
  {InterceptedOnSuccess2, :other_to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success, 3}],
  {InterceptedOnSuccess3, :other_to_intercept, 1} => [on_success: {OnSuccess.Callback, :on_success, 3}],

  # on error tests
  {InterceptedOnError1, :to_intercept, 0} => [on_error: {OnError.Callback, :on_error, 3}],
  {InterceptedOnError2, :to_intercept, 0} => [on_error: {OnError.Callback, :on_error, 3}],
  {InterceptedOnError2, :other_to_intercept, 0} => [on_error: {OnError.Callback, :on_error, 3}],
  {InterceptedOnError3, :other_to_intercept, 1} => [on_error: {OnError.Callback, :on_error, 3}],

  # wrapper tests
  {InterceptedByWrapper1, :to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_result, 2}],
  {InterceptedByWrapper2, :to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_result, 2}],
  {InterceptedByWrapper2, :other_to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_result, 2}],
  {InterceptedByWrapper3, :other_to_intercept, 1} => [wrapper: {Wrapper.Callback, :wrap_returns_result, 2}],
  {InterceptedByWrapper4, :to_intercept, 0} => [wrapper: {Wrapper.Callback, :wrap_returns_hello, 2}],

  # these configs will be overridden by own the module own configuration
  {InterceptedOnAfterOwnConfiguration1, :to_intercept, 0} => [after: {After.Callback, :right_after, 2}],
}

  def get_intercept_config(), do: @config
end
