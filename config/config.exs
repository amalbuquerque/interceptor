use Mix.Config

config :interceptor,
  config_searcher: Interceptor.Configuration.Searcher

import_config "#{Mix.env()}.exs"
