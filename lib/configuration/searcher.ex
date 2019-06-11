defmodule Interceptor.Configuration.Searcher do

  @callback search_intercept_config_modules() :: list()

  @standard_apps [:mix, :compiler, :logger, :ssl, :hex, :kernel, :public_key, :stdlib, :crypto, :elixir, :inets, :asn1, :iex, :makeup_elixir, :earmark, :nimble_parsec, :ex_doc, :makeup, :interceptor]

  @get_intercept_config_function :get_intercept_config

  def search_intercept_config_modules do
    Application.loaded_applications()
    |> Enum.map(fn {app, _desc, _version} -> app end)
    |> Enum.reject(fn app -> app in @standard_apps end)
    |> Enum.flat_map(&Application.spec(&1, :modules))
    |> Enum.filter(&function_exported?(&1, @get_intercept_config_function, 0))
  end
end
