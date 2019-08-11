defmodule Interceptor.Configuration do

  alias Interceptor.Configurator

  def debug_mode? do
    debug_mode? = Application.get_env(:interceptor, :debug, false)

    case is_boolean(debug_mode?) do
      true -> debug_mode?
      _ -> false
    end
  end

  def get_interceptor_module_function_for({module, function, args} = _to_intercept, interception_type) when is_list(args) do
    mfa_to_intercept = {module, function, length(args)}

    get_interceptor_module_function_for(mfa_to_intercept, interception_type)
  end

  def get_interceptor_module_function_for({module, _function, _arity} = to_intercept, interception_type) do
    interception_configuration = get_configuration(module)
    configuration = interception_configuration[to_intercept]

    configuration && Keyword.get(configuration, interception_type)
  end

  def mfa_is_intercepted?({_module, _function, _args} = mfa) do
    [
      get_interceptor_module_function_for(mfa, :before),
      get_interceptor_module_function_for(mfa, :after),
      get_interceptor_module_function_for(mfa, :on_success),
      get_interceptor_module_function_for(mfa, :on_error),
      get_interceptor_module_function_for(mfa, :wrapper)
    ]
    |> Enum.reduce(false,
      fn intercept_config, acc -> acc || intercept_config != nil end)
  end

  def get_global_configuration() do
    Application.get_env(:interceptor, :configuration)
    |> case do
      config when is_map(config) -> config
      config_module ->
        config_module
        |> config_module_exists?()
        |> get_configuration_from_module()
    end
  end

  def get_configuration(module) do
    global_config = get_global_configuration()

    own_config = get_own_configuration(module)
    Map.merge(global_config, own_config)
  end

  defp get_own_configuration(module) do
    case Module.get_attribute(module, :own_config) do
      config when is_map(config) ->
        Configurator.transform_streamlined_config_to_tuple_config(config)
      module ->
        module
        |> config_module_exists?()
        |> get_configuration_from_module()
    end
  end

  defp config_module_exists?(module) do
    {ensure_result, _compiled_module} = Code.ensure_compiled(module)
    compiled? = ensure_result == :module

    defines_function? = [__info__: 1, get_intercept_config: 0]
    |> Enum.map(fn {name, arity} -> function_exported?(module, name, arity) end)
    |> Enum.all?(&(&1))

    {compiled? && defines_function?, module}
  end

  defp get_configuration_from_module({false, nil}), do: %{}

  defp get_configuration_from_module({false, module}),
    do: raise "Your interceptor configuration is pointing to #{inspect(module)}, an invalid (non-existent?) module. Please check your configuration and try again. The module needs to exist and expose the get_intercept_config/0 function."

  defp get_configuration_from_module({true, module}), do: module.get_intercept_config()
end
