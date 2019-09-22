defmodule InterceptConfig do
  @config %{
    ################# `Interceptor.intercept do ... end` tests

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
    {InterceptedOnAfter4, :to_intercept_guarded, 1} => [after: {After.Callback, :right_after, 2}],
    {InterceptedOnAfter5, :it_has_threes, 1} => [after: {After.Callback, :right_after, 2}],
    {InterceptedOnAfter5, :its_abc, 1} => [after: {After.Callback, :right_after, 2}],

    # on success tests
    {InterceptedOnSuccess1, :to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success, 3}],
    {InterceptedOnSuccess2, :to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success, 3}],
    {InterceptedOnSuccess2, :other_to_intercept, 0} => [on_success: {OnSuccess.Callback, :on_success, 3}],
    {InterceptedOnSuccess3, :other_to_intercept, 1} => [on_success: {OnSuccess.Callback, :on_success, 3}],
    {InterceptedOnSuccess3, :trickier_args_function, 6} => [on_success: {OnSuccess.Callback, :on_success, 3}],
    {InterceptedOnSuccess4, :with_struct, 1} => [on_success: {OnSuccess.Callback, :on_success, 3}],
    {InterceptedOnSuccess4, :with_structs, 2} => [on_success: {OnSuccess.Callback, :on_success, 3}],
    {InterceptedOnSuccess4, :with_struct_already_assigned, 1} => [on_success: {OnSuccess.Callback, :on_success, 3}],

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

    # edge cases
    {InterceptedEdgeCases1, :to_intercept, 3} => [on_success: {EdgeCases.Callbacks, :success_cb, 3}, on_error: {EdgeCases.Callbacks, :error_cb, 3}],
    {InterceptedEdgeCases1, :intercept_with_prefix, 1} => [on_success: {EdgeCases.Callbacks, :success_cb, 3}, on_error: {EdgeCases.Callbacks, :error_cb, 3}],

    # these configs will be overridden by the module own configuration
    {InterceptedOnAfterOwnConfiguration1, :to_intercept, 0} => [after: {After.Callback, :right_after, 2}],

    ################# `@intercept :true` tests

    # on before tests
    {AnnotatedInterceptedOnBefore1, :to_intercept, 0} => [before: {AnnotatedBefore.Callback, :before, 1}],
    {AnnotatedInterceptedOnBefore2, :to_intercept, 0} => [before: {AnnotatedBefore.Callback, :before, 1}],
    {AnnotatedInterceptedOnBefore2, :other_to_intercept, 0} => [before: {AnnotatedBefore.Callback, :before, 1}],
    {AnnotatedInterceptedOnBefore3, :other_to_intercept, 1} => [before: {AnnotatedBefore.Callback, :before, 1}],
    {AnnotatedInterceptedOnBefore4, :to_intercept, 0} => [before: {AnnotatedBefore.Callback, :before, 1}],

    # on after tests
    {AnnotatedInterceptedOnAfter1, :to_intercept, 0} => [after: {AnnotatedAfter.Callback, :right_after, 2}],
    {AnnotatedInterceptedOnAfter2, :to_intercept, 0} => [after: {AnnotatedAfter.Callback, :right_after, 2}],
    {AnnotatedInterceptedOnAfter2, :other_to_intercept, 0} => [after: {AnnotatedAfter.Callback, :right_after, 2}],
    {AnnotatedInterceptedOnAfter3, :other_to_intercept, 1} => [after: {AnnotatedAfter.Callback, :right_after, 2}],
    {AnnotatedInterceptedOnAfter4, :to_intercept_guarded, 1} => [after: {AnnotatedAfter.Callback, :right_after, 2}],
    {AnnotatedInterceptedOnAfter5, :it_has_threes, 1} => [after: {AnnotatedAfter.Callback, :right_after, 2}],
    {AnnotatedInterceptedOnAfter5, :its_abc, 1} => [after: {AnnotatedAfter.Callback, :right_after, 2}],

    # on success tests
    {AnnotatedInterceptedOnSuccess1, :to_intercept, 0} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],
    {AnnotatedInterceptedOnSuccess2, :to_intercept, 0} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],
    {AnnotatedInterceptedOnSuccess2, :other_to_intercept, 0} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],
    {AnnotatedInterceptedOnSuccess3, :other_to_intercept, 1} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],
    {AnnotatedInterceptedOnSuccess3, :trickier_args_function, 6} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],
    {AnnotatedInterceptedOnSuccess4, :with_struct, 1} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],
    {AnnotatedInterceptedOnSuccess4, :with_structs, 2} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],
    {AnnotatedInterceptedOnSuccess4, :with_struct_already_assigned, 1} => [on_success: {AnnotatedOnSuccess.Callback, :on_success, 3}],

    # on error tests
    {AnnotatedInterceptedOnError1, :to_intercept, 0} => [on_error: {AnnotatedOnError.Callback, :on_error, 3}],
    {AnnotatedInterceptedOnError2, :to_intercept, 0} => [on_error: {AnnotatedOnError.Callback, :on_error, 3}],
    {AnnotatedInterceptedOnError2, :other_to_intercept, 0} => [on_error: {AnnotatedOnError.Callback, :on_error, 3}],
    {AnnotatedInterceptedOnError3, :other_to_intercept, 1} => [on_error: {AnnotatedOnError.Callback, :on_error, 3}],

    # wrapper tests
    {AnnotatedInterceptedByWrapper1, :to_intercept, 0} => [wrapper: {AnnotatedWrapper.Callback, :wrap_returns_result, 2}],
    {AnnotatedInterceptedByWrapper2, :to_intercept, 0} => [wrapper: {AnnotatedWrapper.Callback, :wrap_returns_result, 2}],
    {AnnotatedInterceptedByWrapper2, :other_to_intercept, 0} => [wrapper: {AnnotatedWrapper.Callback, :wrap_returns_result, 2}],
    {AnnotatedInterceptedByWrapper3, :other_to_intercept, 1} => [wrapper: {AnnotatedWrapper.Callback, :wrap_returns_result, 2}],
    {AnnotatedInterceptedByWrapper4, :to_intercept, 0} => [wrapper: {AnnotatedWrapper.Callback, :wrap_returns_hello, 2}],

    # edge cases
    {AnnotatedInterceptedEdgeCases1, :to_intercept, 3} => [on_success: {AnnotatedEdgeCases.Callbacks, :success_cb, 3}, on_error: {AnnotatedEdgeCases.Callbacks, :error_cb, 3}],
    {AnnotatedInterceptedEdgeCases1, :intercept_with_prefix, 1} => [on_success: {AnnotatedEdgeCases.Callbacks, :success_cb, 3}, on_error: {AnnotatedEdgeCases.Callbacks, :error_cb, 3}],

    # these configs will be overridden by the module own configuration
    {AnnotatedInterceptedOnAfterOwnConfiguration1, :to_intercept, 0} => [after: {After.Callback, :right_after, 2}],
  }

  def get_intercept_config(), do: @config
end
