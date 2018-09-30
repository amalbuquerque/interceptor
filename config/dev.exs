use Mix.Config

config :interceptor, configuration: %{
  {Foo, :abc, 1} => [
    before: {Outsider, :before},
    after: {Outsider, :right_after},
    on_success: {Outsider, :on_success},
    on_error: {Outsider, :on_error},
  ],
  {Foo, :yyy, 0} => [
    wrapper: {Outsider, :wrapper}
  ]
}
