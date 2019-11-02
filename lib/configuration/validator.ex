defmodule Interceptor.Configuration.Validator do
  alias Interceptor.Utils
  alias Interceptor.Configuration

  @config_searcher Application.get_env(:interceptor, :config_searcher) || Interceptor.Configuration.Searcher

  def check_if_intercepted_functions_exist(),
    do: _check_if_intercepted_functions_exist(Configuration.debug_mode?())

  def _check_if_intercepted_functions_exist(_debug = false), do: :skip_intercept_config_validation
  def _check_if_intercepted_functions_exist(_debug = true) do
    modules_to_check = @config_searcher.search_intercept_config_modules()

    all_exist? = modules_to_check
                 |> Enum.map(&get_intercept_config_from_module/1)
                 |> Enum.flat_map(&Enum.map(&1, fn
                   # we don't check wildcarded MFAs
                   {{_m, f, a}, _callbacks} when f == :* or a == :* -> true
                   {{m, f, a}, _callbacks} -> Utils.check_if_mfa_exists(m, f, a)
                 end))
                 |> Enum.reduce(true, fn exists?, acc -> acc and exists? end)

    IO.puts("Checking interceptor configuration defined by the following modules: #{inspect(modules_to_check)}\nAll functions to intercept are exported: #{all_exist?}")

    all_exist?
  end

  defp get_intercept_config_from_module(module),
    do: apply(module, :get_intercept_config, [])
end
