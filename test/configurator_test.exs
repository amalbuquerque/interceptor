defmodule ConfiguratorTest do
  use ExUnit.Case

  describe "simple streamlined intercept configs" do
    test "it converts those streamlined configs to the expected tuple-based config" do
      expected = %{
        {InterceptedOnBefore1, :to_intercept, 0} =>
          [before: {Before.Callback, :before, 1}],
        {Bla.Ble.Bli.Module.Name.Big.TooBig, :to_intercept, 0} =>
          [after: {After.Callback, :right_after, 2}],
      }
      assert expected == StreamlinedInterceptConfig.get_intercept_config()
    end
  end

  describe "one streamlined intercept config with all callbacks" do
    test "it converts those streamlined configs to the expected tuple-based config" do
      expected = %{
        {
          InterceptedOnBefore1, :to_intercept, 0} => [
            before: {Before.Callback, :before, 1},
            after: {After.Callback, :right_after, 2},
            on_success: {Success.Callback, :if_everything_ok, 3},
            on_error: {Error.Callback, :if_borked, 3},
          ],
      }
      assert expected == StreamlinedInterceptConfig2.get_intercept_config()
    end
  end

  describe "one streamlined intercept config with MFAs in tuple and string formats" do
    test "with the MFA of the intercepted function already in a tuple format, it converts those streamlined configs to the expected tuple-based config" do
      expected = %{
        {
          InterceptedOnBefore1, :to_intercept, 0} => [
            before: {Before.Callback, :before, 1},
            after: {After.Callback, :right_after, 2},
            on_success: {Success.Callback, :if_everything_ok, 3},
            on_error: {Error.Callback, :if_borked, 3},
          ],
      }
      assert expected == StreamlinedInterceptConfigMixedFormat.get_intercept_config()
    end

    test "with the MFA of some of the callback functions already in a tuple format, it converts those streamlined configs to the expected tuple-based config" do
      expected = %{
        {
          InterceptedOnBefore1, :to_intercept, 0} => [
            before: {Before.Callback, :before, 1},
            after: {After.Callback, :right_after, 2},
            on_success: {Success.Callback, :if_everything_ok, 3},
            on_error: {Error.Callback, :if_borked, 3},
          ],
      }
      assert expected == StreamlinedInterceptConfigMixedFormat2.get_intercept_config()
    end
  end

  describe "one bad intercept config" do
    test "it raises the expected error" do
      assert_raise RuntimeError, ~r/Invalid MFA/, fn ->
        StreamlinedInterceptConfigBad.get_intercept_config()
      end
    end
  end
end
