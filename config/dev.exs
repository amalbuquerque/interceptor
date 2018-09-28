use Mix.Config

config :interceptor, configuration: %{
  {Foo, :abc, 1} => [
    on_before: {Outsider, :on_before, 1},
    on_after: {Outsider, :on_after, 2},
    on_success: {Outsider, :on_success},
    on_error: {Outsider, :on_error}
  ]
}
