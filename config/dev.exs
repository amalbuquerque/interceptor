use Mix.Config

config :interceptor, configuration: %{
  {Pig, :hi_there, 0} => [
    on_success: {Outsider, :on_success, 3}
  ],
  {Pig, :hi_there_big, 0} => [
    on_success: {Outsider, :on_success, 3}
  ],
  {Pig, :hi, 1} => [
    on_success: {Outsider, :on_success, 3}
  ],
  {Foo, :abc, 1} => [
    before: {Outsider, :before, 1},
    after: {Outsider, :right_after, 2},
    on_success: {Outsider, :on_success, 3},
    on_error: {Outsider, :on_error, 3},
  ],
  {Foo, :yyy, 0} => [
    wrapper: {Outsider, :wrapper, 2}
  ]
},
debug: false
