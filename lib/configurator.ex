defmodule Interceptor.Configurator do

  alias Interceptor.Utils

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :interceptions, accumulate: true)

      @before_compile unquote(__MODULE__)

      def debug_intercept_config(), do: get_intercept_config()
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def get_intercept_config() do
        @interceptions
        |> Enum.reverse()
        |> transform_streamlined_config_to_tuple_config()
      end
    end
  end

  @doc """
  This function converts a map or a list of 2-element tuples (i.e. any structure
  that can be iterated with `Enum.map/1` as a list of 2-element tuples) into a
  "proper" (i.e. tuple-based) intercept configuration map. Each
  element is a `{mfa_to_intercept, callbacks}` tuple, where `mfa_to_intercept`
  is the MFA of the function to intercept as a `"Module.function/arity"` string,
  and `callbacks` is a keyword list whose keys may be one of `:before, :after,
  :on_success, :on_error or :wrapper`, and the values the callback functions to
  call also as a `"Module.function/arity"` string.

  If instead of a `"Module.function/arity"` string, a function is already in
  the MFA tuple format, i.e., it is already written as {Module, :function, 2},
  instead of `"Module.function/2"`, the transformation won't do nothing.
  """
  def transform_streamlined_config_to_tuple_config(intercept_config) do
    intercept_config
    |> Enum.map(fn {mfa_to_intercept, callbacks} ->
      to_intercept = Utils.get_mfa_from_string(mfa_to_intercept)

      {to_intercept, convert_callbacks_to_mfa(callbacks)}
    end)
    |> Enum.into(%{})
  end

  defp convert_callbacks_to_mfa([callback | rest]),
    do: [convert_callback_to_mfa(callback) | convert_callbacks_to_mfa(rest)]

  defp convert_callbacks_to_mfa([]), do: []

  defp convert_callback_to_mfa({type, mfa_string}) when type in [:before, :after, :on_success, :on_error, :wrapper] do
    mfa = Utils.get_mfa_from_string(mfa_string)

    {type, mfa}
  end

  defmacro intercept(mfa_to_intercept, callbacks) do
    quote bind_quoted: [mfa_to_intercept: mfa_to_intercept, callbacks: callbacks] do
      @interceptions {mfa_to_intercept, callbacks}
    end
  end
end
