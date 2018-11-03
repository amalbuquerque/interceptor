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
        |> Enum.map(fn {mfa_to_intercept, callbacks} ->
          to_intercept = Utils.get_mfa_from_string(mfa_to_intercept)

          {to_intercept, convert_callbacks_to_mfa(callbacks)}
        end)
      end
    end
  end

  def convert_callbacks_to_mfa([callback | rest]),
    do: [convert_callback_to_mfa(callback) | convert_callbacks_to_mfa(rest)]

  def convert_callbacks_to_mfa([]), do: []

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
