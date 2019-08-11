use Mix.Config

config :interceptor,
  config_searcher: Interceptor.Configuration.SearcherMock,
  configuration: InterceptConfig,
  debug: true
